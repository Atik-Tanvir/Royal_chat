import 'package:flutter/material.dart';

class PartyCategoryBar extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onSelectCategory;

  const PartyCategoryBar({
    super.key,
    required this.selectedCategory,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'All', 'icon': Icons.grid_view_rounded, 'color': const Color(0xFF00E5A3)},
      {'name': 'Lucky Number', 'icon': Icons.casino_rounded, 'color': const Color(0xFF8B5CF6)},
      {'name': 'Lucky Race', 'icon': Icons.sports_motorsports_rounded, 'color': const Color(0xFFFFB800)},
      {'name': 'Chatroom', 'icon': Icons.forum_rounded, 'color': const Color(0xFFFF6B6B)},
      {'name': 'PK', 'icon': Icons.offline_bolt_rounded, 'color': const Color(0xFFFF3366)},
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final String name = cat['name'] as String;
          final IconData icon = cat['icon'] as IconData;
          final Color color = cat['color'] as Color;
          final bool isSelected = selectedCategory == name;

          return GestureDetector(
            onTap: () => onSelectCategory(name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.9), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
