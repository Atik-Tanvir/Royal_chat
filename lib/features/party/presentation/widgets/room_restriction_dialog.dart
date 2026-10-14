import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RoomRestrictionDialog extends StatefulWidget {
  final VoidCallback onJoinHotRoom;
  final VoidCallback onBypassCreate;

  const RoomRestrictionDialog({
    super.key,
    required this.onJoinHotRoom,
    required this.onBypassCreate,
  });

  static void show(
    BuildContext context, {
    required VoidCallback onJoinHotRoom,
    required VoidCallback onBypassCreate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => RoomRestrictionDialog(
        onJoinHotRoom: onJoinHotRoom,
        onBypassCreate: onBypassCreate,
      ),
    );
  }

  @override
  State<RoomRestrictionDialog> createState() => _RoomRestrictionDialogState();
}

class _RoomRestrictionDialogState extends State<RoomRestrictionDialog> {
  int _secondsLeft = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        if (mounted) {
          Navigator.pop(context);
          widget.onJoinHotRoom();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // White Card
          Container(
            margin: const EdgeInsets.only(top: 40),
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Create a room at Wealth Lv1+',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Reach Wealth Level 1 by sending gifts or recharging coins to host your own room.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Mint Green Button: Join Hot Room
                GestureDetector(
                  onTap: () {
                    _timer?.cancel();
                    Navigator.pop(context);
                    widget.onJoinHotRoom();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00C853).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Join Hot Room (${_secondsLeft}s)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Bypass option for demo/creator
                TextButton(
                  onPressed: () {
                    _timer?.cancel();
                    Navigator.pop(context);
                    widget.onBypassCreate();
                  },
                  child: const Text(
                    'Creator Mode (Host Room Now)',
                    style: TextStyle(color: AppColors.gemEmerald, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 3D Mint Bell with Sparkles
          Positioned(
            top: 0,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF69F0AE), Color(0xFF00BFA5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00BFA5).withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),

          // Close button on top right
          Positioned(
            top: 50,
            right: 12,
            child: GestureDetector(
              onTap: () {
                _timer?.cancel();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.black54, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
