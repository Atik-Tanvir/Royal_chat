import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Shared bottom-sheet dialog allowing players to pick a public group table
/// or join/create a private Group Room ID in Group Mode.
class GameGroupPickerSheet {
  static void show(
    BuildContext context, {
    required String currentRoomId,
    required void Function(String roomId, String roomName) onSelectRoom,
  }) {
    final codeController = TextEditingController();
    final presetTables = [
      {'id': 'royal_group_1', 'name': 'Royal Group #1', 'players': '18 Online'},
      {'id': 'royal_group_2', 'name': 'VIP Squad Room', 'players': '12 Online'},
      {'id': 'royal_group_3', 'name': 'Lucky Star Group', 'players': '9 Online'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150829),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👥 Select or Join Group Table',
              style: TextStyle(
                color: AppColors.goldCoin,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            ...presetTables.map((t) {
              final isSelected = currentRoomId == t['id'];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? AppColors.goldCoin
                      : Colors.white.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.groups_rounded,
                    color: isSelected ? Colors.black : Colors.white,
                  ),
                ),
                title: Text(
                  t['name']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  t['players']!,
                  style: const TextStyle(color: AppColors.gemEmerald, fontSize: 11),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isSelected ? AppColors.goldCoin : AppColors.gemEmerald,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onSelectRoom(t['id']!, t['name']!);
                  },
                  child: Text(
                    isSelected ? 'Active' : 'Join',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }),
            const Divider(color: Colors.white12, height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: codeController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter private room code (e.g. 7788)',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                      filled: true,
                      fillColor: Colors.black38,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldCoin,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final code = codeController.text.trim();
                    if (code.isNotEmpty) {
                      Navigator.pop(ctx);
                      onSelectRoom('custom_$code', 'Group #$code');
                    }
                  },
                  child: const Text(
                    'Join / Create',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
