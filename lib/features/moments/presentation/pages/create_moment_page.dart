import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../../../../core/config/supabase_config.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';

class CreateMomentPage extends StatefulWidget {
  const CreateMomentPage({super.key});

  @override
  State<CreateMomentPage> createState() => _CreateMomentPageState();
}

class _CreateMomentPageState extends State<CreateMomentPage> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _attachedImages = [];
  bool _isUploading = false;
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
    if (_selectedLocation != null) fullContent += ' 📍$_selectedLocation';

    context.read<MomentsBloc>().add(
          CreateMomentEvent(
            content: fullContent,
            imageUrls: _attachedImages,
          ),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ Moment published successfully to Supabase!'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final bytes = await pickedFile.readAsBytes();
      final ext = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';
      final user = SupabaseConfig.client.auth.currentUser;
      final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
      final r2Url = await R2StorageService.instance.uploadMomentPhoto(
        bytes: bytes,
        userId: userId,
        extension: ext,
      );

      if (r2Url != null && mounted) {
        setState(() {
          _attachedImages.add(r2Url);
          _isUploading = false;
        });
      } else if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo selected, uploaded via R2 Cloudflare.'),
            backgroundColor: AppColors.gemEmerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image selection note: $e')),
        );
      }
    }
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: _isUploading ? null : _onPublish,
              child: Container(
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
              maxLines: 8,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Share a moment with Royal Live community...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                border: InputBorder.none,
                counterText: '',
              ),
              onChanged: (_) => setState(() {}),
            ),

            // Chips Row: # Topic, @ User, 📍 Location
            Row(
              children: [
                _buildActionChip(
                  iconText: '#',
                  label: _selectedTopic ?? 'Topic',
                  isSelected: _selectedTopic != null,
                  onTap: () {
                    setState(() {
                      _selectedTopic = _selectedTopic == null ? 'RoyalParty' : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
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
                const SizedBox(width: 8),
                _buildActionChip(
                  iconText: '📍',
                  label: _selectedLocation ?? 'Location',
                  isSelected: _selectedLocation != null,
                  onTap: () {
                    setState(() {
                      _selectedLocation = _selectedLocation == null ? 'Dhaka' : null;
                    });
                  },
                ),
                const Spacer(),
                Text(
                  '${_textController.text.length}/1000',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 16),

            // Upload Tiles Row (Image / Video)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                // Render attached images
                ..._attachedImages.asMap().entries.map((entry) {
                  return Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(entry.value),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _attachedImages.removeAt(entry.key)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
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

                // Photo Picker Tile (Calls ImagePicker & R2 Storage)
                GestureDetector(
                  onTap: _isUploading ? null : _pickAndUploadPhoto,
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
