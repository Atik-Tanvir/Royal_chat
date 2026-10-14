import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
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
        content: Text('✨ Moment published successfully!'),
        backgroundColor: AppColors.gemEmerald,
      ),
    );

    Navigator.pop(context);
  }

  void _addMockPhoto() {
    setState(() {
      _attachedImages.add('https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/500/500');
    });
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
              onTap: _onPublish,
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.gemEmerald,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
                hintText: 'Say something...',
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
                      _selectedTopic = _selectedTopic == null ? 'Kanchanjangha' : null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  iconText: '@',
                  label: 'User',
                  isSelected: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select friend to mention')),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildActionChip(
                  iconText: '📍',
                  label: _selectedLocation ?? 'Location',
                  isSelected: _selectedLocation != null,
                  onTap: () {
                    setState(() {
                      _selectedLocation = _selectedLocation == null ? 'Tetulia' : null;
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

                // Photo Picker Tile
                GestureDetector(
                  onTap: _addMockPhoto,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_outlined, color: Color(0xFF94A3B8), size: 36),
                  ),
                ),

                // Video Picker Tile
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Select video clip from library.')),
                    );
                  },
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_circle_outline_rounded, color: Color(0xFF94A3B8), size: 36),
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
          color: isSelected ? const Color(0xFFE8F7F2) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.gemEmerald : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(iconText, style: TextStyle(color: isSelected ? AppColors.gemEmerald : const Color(0xFF64748B), fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gemEmerald : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
