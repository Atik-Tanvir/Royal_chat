import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../widgets/moment_media_image.dart';

class CreateMomentPage extends StatefulWidget {
  const CreateMomentPage({super.key});

  @override
  State<CreateMomentPage> createState() => _CreateMomentPageState();
}

class _CreateMomentPageState extends State<CreateMomentPage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _attachedImages = [];
  bool _isUploading = false;
  bool _shareToStory = false;
  String? _selectedTopic;
  String? _selectedLocation;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onPublish() {
    final text = _textController.text.trim();
    if (text.isEmpty && _attachedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or attach a photo.')),
      );
      return;
    }

    String fullContent = text;
    if (_selectedTopic != null) fullContent += ' #$_selectedTopic';

    final category = (_selectedTopic == 'TikTokReels' || _selectedTopic == 'Video')
        ? 'Video'
        : (_selectedTopic ?? 'Moments');

    context.read<MomentsBloc>().add(
          CreateMomentEvent(
            content: fullContent,
            imageUrls: _attachedImages,
            category: category,
            location: _selectedLocation,
            shareToStory: _shareToStory,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_shareToStory
            ? '✨ Moment & Story published!'
            : '✨ Moment published!'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final bytes = await pickedFile.readAsBytes();
      final ext = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';
      final userId = AuthSessionManager.currentUserId ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

      final uploadedUrl = await R2StorageService.instance.uploadMomentPhoto(
        bytes: bytes,
        userId: userId,
        extension: ext,
      );

      if (uploadedUrl != null && mounted) {
        setState(() {
          _attachedImages.add(uploadedUrl);
          _isUploading = false;
        });
      } else if (mounted) {
        setState(() => _isUploading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload error: $e')),
        );
      }
    }
  }

  void _showMediaSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.gemEmerald),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.goldCoin),
                title: const Text('Take a Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadPhoto(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(String urlOrDataUri) {
    return MomentMediaImage(
      source: urlOrDataUri,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF1E293B), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Moment',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: _isUploading ? null : _onPublish,
              tooltip: 'Publish Moment',
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _isUploading ? Colors.grey : AppColors.gemEmerald,
                  shape: BoxShape.circle,
                ),
                child: _isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input
            TextField(
              controller: _textController,
              maxLines: 7,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Share a moment with Royal Live community...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Chips Row: # Topic, @ Mention, 📍 Location
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionChip(
                  iconText: '#',
                  label: _selectedTopic ?? 'Topic',
                  isSelected: _selectedTopic != null,
                  onTap: () {
                    _showTopicSelector();
                  },
                ),
                _buildActionChip(
                  iconText: '@',
                  label: 'Mention',
                  isSelected: false,
                  onTap: () {
                    setState(() {
                      _textController.text = '${_textController.text} @RoyalFriend ';
                    });
                  },
                ),
                _buildActionChip(
                  iconText: '📍',
                  label: _selectedLocation ?? 'Location',
                  isSelected: _selectedLocation != null,
                  onTap: () {
                    _showLocationSelector();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${_textController.text.length}/1000',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF3F7F4),
                borderRadius: BorderRadius.circular(14),
              ),
              child: SwitchListTile.adaptive(
                value: _shareToStory,
                activeColor: AppColors.accentOrange,
                onChanged: (v) => setState(() => _shareToStory = v),
                title: const Text(
                  'Also Share to My 24h Story',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                subtitle: const Text(
                  'Highlight this status & photo in top Stories bar',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Attached Media Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._attachedImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImagePreview(entry.value),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _attachedImages.removeAt(entry.key)),
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // Add Photo Tile
                GestureDetector(
                  onTap: _isUploading ? null : _showMediaSourcePicker,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: _isUploading
                        ? const Center(
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gemEmerald),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF94A3B8), size: 28),
                              SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton.icon(
            onPressed: _isUploading ? null : _onPublish,
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : const Icon(Icons.send_rounded, size: 18),
            label: Text(_isUploading ? 'Uploading...' : 'Publish Moment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gemEmerald,
              foregroundColor: Colors.black,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  void _showTopicSelector() {
    final topics = ['TikTokReels', 'Video', 'RoyalParty', 'VoiceRoom', 'LuckyRace', 'MusicLive', 'Hangout'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Topic', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: topics.map((t) {
                  final isSel = _selectedTopic == t;
                  return ChoiceChip(
                    label: Text('#$t'),
                    selected: isSel,
                    onSelected: (val) {
                      setState(() => _selectedTopic = val ? t : null);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationSelector() {
    final locations = ['Dhaka, Bangladesh', 'Chittagong, BD', 'Tokyo, Japan', 'Dubai, UAE', 'Manila, Philippines'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ...locations.map((loc) => ListTile(
                    leading: const Icon(Icons.location_on_rounded, color: AppColors.gemEmerald),
                    title: Text(loc),
                    onTap: () {
                      setState(() => _selectedLocation = loc);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required String iconText,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gemEmerald.withValues(alpha: 0.15) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.gemEmerald : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              iconText,
              style: TextStyle(
                color: isSelected ? AppColors.gemEmerald : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gemEmerald : const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
