import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

/// Shared reusable Coin Bet Input & Preset Chip Controls (`- [100] +`, `100`, `500`, `1K`, `5K`).
class GameCoinControlsBar extends StatelessWidget {
  final TextEditingController controller;
  final int currentAmount;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onTextChanged;
  final ValueChanged<int> onPresetSelected;

  const GameCoinControlsBar({
    super.key,
    required this.controller,
    required this.currentAmount,
    required this.onDecrement,
    required this.onIncrement,
    required this.onTextChanged,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQtyButton(icon: '-', onTap: onDecrement),
              const SizedBox(width: 10),
              SizedBox(
                width: 124,
                height: 38,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  onChanged: onTextChanged,
                  style: const TextStyle(
                    color: AppColors.goldCoin,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF110826),
                    contentPadding: EdgeInsets.zero,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.goldCoin,
                        width: 1.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildQtyButton(icon: '+', onTap: onIncrement),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildChipPresetButton('100', 100),
              _buildChipPresetButton('500', 500),
              _buildChipPresetButton('1K', 1000),
              _buildChipPresetButton('5K', 5000),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required String icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFF251642),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.goldCoin, width: 1.8),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(
              color: AppColors.goldCoin,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChipPresetButton(String label, int value) {
    final isSelected = currentAmount == value;

    return GestureDetector(
      onTap: () => onPresetSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.goldCoin
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.white
                : AppColors.goldCoin.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
