import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gemgala_background.dart';
import '../widgets/bucket_prediction_game_view.dart';
import '../widgets/color_prediction_game_view.dart';
import '../widgets/seven_up_game_view.dart';

/// Full-screen or BottomSheet Group Drawer launcher for Royal Games (#1, #2, #3).
class BucketPredictionGamePage extends StatelessWidget {
  final String? partyRoomId;
  final String? partyRoomName;
  final int initialGameIndex;

  const BucketPredictionGamePage({
    super.key,
    this.partyRoomId,
    this.partyRoomName,
    this.initialGameIndex = 0,
  });

  static Future<void> showGroupDrawer(
    BuildContext context, {
    required String roomId,
    required String roomName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PartyGroupGamesDrawer(
        roomId: roomId,
        roomName: roomName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070211),
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        elevation: 0,
        title: const Text(
          '👑 Royal Games Hub',
          style: TextStyle(
            color: AppColors.goldCoin,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GemgalaBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: initialGameIndex == 2
                ? SevenUpGameView(
                    partyRoomId: partyRoomId,
                    partyRoomName: partyRoomName,
                  )
                : initialGameIndex == 1
                    ? ColorPredictionGameView(
                        partyRoomId: partyRoomId,
                        partyRoomName: partyRoomName,
                      )
                    : BucketPredictionGameView(
                        partyRoomId: partyRoomId,
                        partyRoomName: partyRoomName,
                      ),
          ),
        ),
      ),
    );
  }
}

class _PartyGroupGamesDrawer extends StatefulWidget {
  final String roomId;
  final String roomName;

  const _PartyGroupGamesDrawer({
    required this.roomId,
    required this.roomName,
  });

  @override
  State<_PartyGroupGamesDrawer> createState() => _PartyGroupGamesDrawerState();
}

class _PartyGroupGamesDrawerState extends State<_PartyGroupGamesDrawer> {
  int _selectedGame = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Game Switcher Pills inside Party Room Drawer
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF150829),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.goldCoin.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTab('🪣 Bucket', 0),
                  const SizedBox(width: 4),
                  _buildTab('🎨 Color', 1),
                  const SizedBox(width: 4),
                  _buildTab('🎲 7 Up 7 Down', 2),
                ],
              ),
            ),
            if (_selectedGame == 0)
              BucketPredictionGameView(
                partyRoomId: widget.roomId,
                partyRoomName: widget.roomName,
                isDrawerMode: true,
              )
            else if (_selectedGame == 1)
              ColorPredictionGameView(
                partyRoomId: widget.roomId,
                partyRoomName: widget.roomName,
                isDrawerMode: true,
              )
            else
              SevenUpGameView(
                partyRoomId: widget.roomId,
                partyRoomName: widget.roomName,
                isDrawerMode: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedGame == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedGame = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldCoin : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
