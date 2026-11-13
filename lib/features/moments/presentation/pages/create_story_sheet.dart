import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/auth_session_manager.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/r2_storage_service.dart';
import '../bloc/moments_bloc.dart';
import '../bloc/moments_event.dart';
import '../widgets/moment_media_image.dart';

/// Shared gradient palettes used by Status Stories and Story Viewer.
const List<List<Color>> kStoryGradients = [
  [Color(0xFF0E6B47), Color(0xFF063B27)],
  [Color(0xFFFF8F00), Color(0xFFE65100)],
  [Color(0xFF7B1FA2), Color(0xFF4A148C)],
  [Color(0xFF1565C0), Color(0xFF0D47A1)],
  [Color(0xFFC2185B), Color(0xFF880E4F)],
  [Color(0xFF00796B), Color(0xFF004D40)],
];

/// Modal sheet to compose a 24h Status Story or upload a Photo Story.
class CreateStorySheet extends StatefulWidget {
  const CreateStorySheet({super.key});

  @override
  State<CreateStorySheet> createState() => _CreateStorySheetState();
}

class _CreateStorySheetState extends State<CreateStorySheet> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _uploadedMediaUrl;
  int _selectedGradient = 0;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (file == null) return;
    setState(() => _isUploading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final url = await R2StorageService.instance.uploadMomentPhoto(
        bytes: bytes,
        userId: AuthSessionManager.currentUserId ?? 'royal_guest',
        extension: ext,
      );
      if (mounted) {
        setState(() => _uploadedMediaUrl = url);
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _publishStory() {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _uploadedMediaUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Write a status or pick a photo for your Story.'),
        ),
      );
      return;
    }

    context.read<MomentsBloc>().add(
          CreateStoryEvent(
            caption: caption,
            mediaUrl: _uploadedMediaUrl,
            bgGradientIndex: _selectedGradient,
          ),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colors = kStoryGradients[_selectedGradient % kStoryGradients.length];

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Share Story & Status (24h)',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Live Story Preview Card
            Container(
              height: 210,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_uploadedMediaUrl != null)
                      MomentMediaImage(
                        source: _uploadedMediaUrl!,
                        fit: BoxFit.cover,
                      ),
                    Container(
                      color: _uploadedMediaUrl != null
                          ? Colors.black.withOpacity(0.28)
                          : Colors.transparent,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: TextField(
                          controller: _captionController,
                          maxLines: 4,
                          minLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 8),
                            ],
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Type your status or story caption...',
                            hintStyle: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_uploadedMediaUrl != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _uploadedMediaUrl = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Theme gradient dots + photo picker
            Row(
              children: [
                const Text(
                  'Theme:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(kStoryGradients.length, (idx) {
                        final selected = idx == _selectedGradient;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedGradient = idx),
                          child: Container(
                            width: 28,
                            height: 28,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: kStoryGradients[idx],
                              ),
                              border: Border.all(
                                color: selected
                                    ? AppColors.accentOrange
                                    : Colors.grey.shade300,
                                width: selected ? 2.5 : 1,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickPhoto,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_camera_rounded, size: 17),
                  label: Text(_uploadedMediaUrl == null ? 'Add Photo' : 'Change'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryGreen,
                    side: const BorderSide(color: AppColors.primaryGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : _publishStory,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Share to Story',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
