import 'dart:async';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';

/// 1-on-1 Private Call Page (Audio / Video) with Per-Minute Gems Billing
/// and interactive Beauty Filter controls (Smooth, Whiten, Slim, Rosy).
class OneOnOneCallPage extends StatefulWidget {
  final String calleeId;
  final String calleeName;
  final String calleeAvatar;
  final String calleeCountry;
  final bool isVideoCall;
  final int gemsPerMinute;

  const OneOnOneCallPage({
    super.key,
    required this.calleeId,
    required this.calleeName,
    this.calleeAvatar = '',
    this.calleeCountry = '🇧🇩',
    this.isVideoCall = true,
    this.gemsPerMinute = 240, // 240 for video, 120 for voice by default
  });

  @override
  State<OneOnOneCallPage> createState() => _OneOnOneCallPageState();
}

class _OneOnOneCallPageState extends State<OneOnOneCallPage>
    with TickerProviderStateMixin {
  // Call State
  bool _isConnected = false;
  int _secondsElapsed = 0;
  Timer? _callTimer;
  int _totalGemsDeducted = 0;

  // Audio / Video Controls
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;

  // Beauty Filter Parameters (0.0 to 1.0)
  double _smoothSkin = 0.65;
  double _whitenSkin = 0.50;
  double _faceSlimming = 0.40;
  double _rosyCheeks = 0.45;
  double _eyeBrightening = 0.30;
  String _activePreset = 'Natural';

  // Animations
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _isVideoEnabled = widget.isVideoCall;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    // Simulate connection delay for authentic mobile experience
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isConnected = true);
        _startCallTimerAndBilling();
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startCallTimerAndBilling() {
    // Initial 1st minute charge upon connection
    _deductGemsCycle();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsElapsed++;
      });

      // Deduct gems on every full minute elapsed
      if (_secondsElapsed > 0 && _secondsElapsed % 60 == 0) {
        _deductGemsCycle();
      }
    });
  }

  Future<void> _deductGemsCycle() async {
    final rate = widget.isVideoCall ? widget.gemsPerMinute : (widget.gemsPerMinute ~/ 2);
    final profileBloc = context.read<ProfileBloc>();
    final currentGemBalance = profileBloc.state.profile.gemBalance;

    if (currentGemBalance < rate && currentGemBalance > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Low Gems balance! You have ${currentGemBalance.toInt()} Gems left ($rate Gems/min).',
          ),
          backgroundColor: Colors.orange.shade800,
          duration: const Duration(seconds: 4),
        ),
      );
    } else if (currentGemBalance <= 0) {
      // In demo/test mode, allow or gently warn
      debugPrint('[1v1 Call] Gems balance zero or negative: $currentGemBalance');
    }

    final newGems = max(0.0, currentGemBalance - rate);
    _totalGemsDeducted += rate;

    profileBloc.add(
      ProfileBalancesUpdatedFromRealtimeEvent(gemBalance: newGems),
    );

    // Sync to Supabase
    try {
      final uid = AuthSessionManager.currentUserId;
      if (uid != null && uid.isNotEmpty) {
        await SupabaseConfig.client
            .from('profiles')
            .update({'gem_balance': newGems})
            .eq('id', uid);
      }
    } catch (e) {
      debugPrint('[1v1 Call] Failed to deduct gems in Supabase: $e');
    }
  }

  String _formatCallDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$mStr:$sStr';
  }

  void _endCall() {
    _callTimer?.cancel();
    _showCallRatingSummaryDialog();
  }

  void _showCallRatingSummaryDialog() {
    int selectedRating = 5;
    final tags = ['Crystal Voice 🎙️', 'HD Video 🌟', 'Polite Host 🥰', 'Very Friendly ✨', 'Loved the Room 💎'];
    final selectedTags = <String>{'Crystal Voice 🎙️', 'HD Video 🌟'};

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dlgContext) => StatefulBuilder(
        builder: (context, setDlgState) {
          return Dialog(
            backgroundColor: const Color(0xFF0C241D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: AppColors.goldCoin, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Call Ended Icon & Title
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      border: Border.all(color: Colors.redAccent, width: 2),
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Call Ended',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Duration: ${_formatCallDuration(_secondsElapsed)}  •  Spent: $_totalGemsDeducted 💎',
                    style: const TextStyle(color: AppColors.goldCoin, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),

                  const Text(
                    'Rate your call experience',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),

                  // 5-Star Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNum <= selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: AppColors.goldCoin,
                          size: 34,
                        ),
                        onPressed: () {
                          setDlgState(() => selectedRating = starNum);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // Feedback Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: tags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return GestureDetector(
                        onTap: () {
                          setDlgState(() {
                            if (isSelected) {
                              selectedTags.remove(tag);
                            } else {
                              selectedTags.add(tag);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gemEmerald.withValues(alpha: 0.25)
                                : Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? AppColors.gemEmerald : Colors.white24,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.goldCoin,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                      onPressed: () {
                        Navigator.pop(dlgContext); // Close dialog
                        Navigator.pop(context); // Exit call screen
                      },
                      child: const Text(
                        'Submit & Finish',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBeautyFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF081F19).withValues(alpha: 0.96),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: const Border(
                top: BorderSide(color: AppColors.gemEmerald, width: 2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 20,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Grabber & Title
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_fix_high_rounded, color: AppColors.goldCoin, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'AI Beauty Filter Engine',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        setSheetState(() {
                          _smoothSkin = 0.0;
                          _whitenSkin = 0.0;
                          _faceSlimming = 0.0;
                          _rosyCheeks = 0.0;
                          _eyeBrightening = 0.0;
                          _activePreset = 'Original';
                        });
                        setState(() {});
                      },
                      child: const Text('Reset', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Preset Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPresetChip('Natural', 0.65, 0.50, 0.40, 0.45, setSheetState),
                      _buildPresetChip('Porcelain', 0.90, 0.85, 0.55, 0.35, setSheetState),
                      _buildPresetChip('Rosy Glow', 0.70, 0.60, 0.45, 0.80, setSheetState),
                      _buildPresetChip('Glamour', 0.95, 0.75, 0.70, 0.70, setSheetState),
                      _buildPresetChip('Soft Matte', 0.50, 0.40, 0.30, 0.25, setSheetState),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Beauty Sliders
                _buildFilterSlider(
                  title: 'Smooth Skin',
                  icon: Icons.face_retouching_natural_rounded,
                  value: _smoothSkin,
                  onChanged: (v) {
                    setSheetState(() => _smoothSkin = v);
                    setState(() {});
                  },
                ),
                _buildFilterSlider(
                  title: 'Skin Whitening',
                  icon: Icons.wb_sunny_rounded,
                  value: _whitenSkin,
                  onChanged: (v) {
                    setSheetState(() => _whitenSkin = v);
                    setState(() {});
                  },
                ),
                _buildFilterSlider(
                  title: 'Face Slimming',
                  icon: Icons.compress_rounded,
                  value: _faceSlimming,
                  onChanged: (v) {
                    setSheetState(() => _faceSlimming = v);
                    setState(() {});
                  },
                ),
                _buildFilterSlider(
                  title: 'Rosy / Blush Tone',
                  icon: Icons.favorite_rounded,
                  value: _rosyCheeks,
                  onChanged: (v) {
                    setSheetState(() => _rosyCheeks = v);
                    setState(() {});
                  },
                ),
                _buildFilterSlider(
                  title: 'Eye Brightening',
                  icon: Icons.remove_red_eye_rounded,
                  value: _eyeBrightening,
                  onChanged: (v) {
                    setSheetState(() => _eyeBrightening = v);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(
    String name,
    double smooth,
    double whiten,
    double slim,
    double rosy,
    void Function(void Function()) setSheetState,
  ) {
    final isSelected = _activePreset == name;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setSheetState(() {
            _activePreset = name;
            _smoothSkin = smooth;
            _whitenSkin = whiten;
            _faceSlimming = slim;
            _rosyCheeks = rosy;
          });
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gemEmerald : Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.goldCoin : Colors.white24,
              width: 1.2,
            ),
          ),
          child: Text(
            name,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSlider({
    required String title,
    required IconData icon,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.goldCoin, size: 18),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.gemEmerald,
                inactiveTrackColor: Colors.white12,
                thumbColor: AppColors.goldCoin,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                trackHeight: 3,
              ),
              child: Slider(
                value: value,
                min: 0.0,
                max: 1.0,
                onChanged: onChanged,
              ),
            ),
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rate = widget.isVideoCall ? widget.gemsPerMinute : (widget.gemsPerMinute ~/ 2);

    return Scaffold(
      backgroundColor: const Color(0xFF041611),
      body: Stack(
        children: [
          // 1. Background / Video Stream Simulation
          if (widget.isVideoCall && _isVideoEnabled)
            _buildRemoteVideoViewport()
          else
            _buildAudioCallBackground(),

          // 2. Top Header Overlay (Callee Info, Call Duration, Gems Rate Ticker)
          _buildTopBar(rate),

          // 3. Floating Picture-in-Picture Local Camera View (for Video Calls)
          if (widget.isVideoCall && _isVideoEnabled) _buildLocalPipWindow(),

          // 4. Beauty Filter Active Effect Layer (Color Grade / Glow Simulation)
          if (_smoothSkin > 0 || _whitenSkin > 0 || _rosyCheeks > 0)
            _buildBeautyShaderOverlay(),

          // 5. Bottom Control Bar (Mute, Speaker, Beauty, Video, End)
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopBar(int rate) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            // Callee Avatar
            CustomAvatar(
              imageUrl: widget.calleeAvatar,
              countryFlag: widget.calleeCountry,
              radius: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.calleeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: _isConnected ? Colors.green.withValues(alpha: 0.3) : Colors.amber.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _isConnected ? Colors.greenAccent : Colors.amberAccent,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          _isConnected ? 'Connected' : 'Calling...',
                          style: TextStyle(
                            color: _isConnected ? Colors.greenAccent : Colors.amberAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.white60, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _isConnected ? _formatCallDuration(_secondsElapsed) : '00:00',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Gems Billing Rate Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '$rate/m',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteVideoViewport() {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Remote Host Visual simulation (fallback image or gradient)
          if (widget.calleeAvatar.isNotEmpty)
            CachedNetworkImage(
              imageUrl: widget.calleeAvatar,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF07241C)),
              errorWidget: (_, __, ___) => _buildFallbackVisual(),
            )
          else
            _buildFallbackVisual(),

          // Dark gradient overlay top and bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.25, 0.7, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackVisual() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [Color(0xFF0F4E3D), Color(0xFF031610)],
          radius: 1.1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.goldCoin, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gemEmerald.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: widget.calleeAvatar.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: widget.calleeAvatar,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFF092C23),
                          child: const Icon(Icons.person, color: Colors.white, size: 64),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.calleeName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '1-on-1 Encrypted Video Stream',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioCallBackground() {
    return SizedBox.expand(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF061B15), Color(0xFF010A07)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Radial Pulsing Sound Waves
              Stack(
                alignment: Alignment.center,
                children: [
                  // Animated Outer Ring
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gemEmerald.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.gemEmerald.withValues(alpha: 0.35),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Animated Middle Ring
                  Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gemEmerald.withValues(alpha: 0.20),
                    ),
                  ),

                  // Host Center Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.goldCoin, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.goldCoin.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: widget.calleeAvatar.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: widget.calleeAvatar,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFF0F3B2E),
                              child: const Icon(Icons.person, color: Colors.white, size: 55),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                widget.calleeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.mic_rounded, color: AppColors.gemEmerald, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _isConnected ? 'In Voice Call (${_formatCallDuration(_secondsElapsed)})' : 'Calling...',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Simulated Animated Voice Spectrum Bars
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(12, (index) {
                      final waveOffset = (sin((_waveController.value * 2 * pi) + (index * 0.5)) + 1) / 2;
                      final barHeight = 8 + (waveOffset * 28);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: 4,
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: AppColors.goldCoin.withValues(alpha: 0.6 + (waveOffset * 0.4)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocalPipWindow() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 70,
      right: 16,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isFrontCamera = !_isFrontCamera;
          });
        },
        child: Container(
          width: 105,
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFF132A22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.goldCoin, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera simulation
                Container(
                  color: const Color(0xFF0E382D),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isFrontCamera ? Icons.face_rounded : Icons.camera_rear_rounded,
                          color: AppColors.gemEmerald,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isFrontCamera ? 'Front Cam' : 'Rear Cam',
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBeautyShaderOverlay() {
    // Dynamic overlay for simulated skin smoothing and rosy glow
    return IgnorePointer(
      child: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(
              255,
              (255 - (_rosyCheeks * 40)).toInt(),
              (255 - (_rosyCheeks * 30)).toInt(),
              _rosyCheeks * 0.12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 1. Mute Mic
            _buildCircleButton(
              icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: _isMuted ? 'Muted' : 'Mic On',
              isActive: !_isMuted,
              activeColor: Colors.white24,
              onTap: () => setState(() => _isMuted = !_isMuted),
            ),

            // 2. Speaker Toggle
            _buildCircleButton(
              icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
              label: _isSpeakerOn ? 'Speaker' : 'Earphone',
              isActive: _isSpeakerOn,
              activeColor: Colors.white24,
              onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
            ),

            // 3. Beauty Filter Modal Toggle
            _buildCircleButton(
              icon: Icons.auto_fix_high_rounded,
              label: 'Beauty',
              isActive: true,
              activeColor: AppColors.goldCoin.withValues(alpha: 0.35),
              iconColor: AppColors.goldCoin,
              onTap: _showBeautyFilterSheet,
            ),

            // 4. Video Toggle (for video calls) or Flip
            if (widget.isVideoCall)
              _buildCircleButton(
                icon: _isVideoEnabled ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                label: _isVideoEnabled ? 'Video' : 'Off',
                isActive: _isVideoEnabled,
                activeColor: Colors.white24,
                onTap: () => setState(() => _isVideoEnabled = !_isVideoEnabled),
              ),

            // 5. End Call Button
            GestureDetector(
              onTap: _endCall,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.redAccent,
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 4),
                  const Text('End', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? activeColor : Colors.black45,
              border: Border.all(
                color: isActive ? Colors.white30 : Colors.white12,
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor ?? (isActive ? Colors.white : Colors.white54),
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
