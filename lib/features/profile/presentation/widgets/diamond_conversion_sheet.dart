import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class DiamondConversionSheet extends StatefulWidget {
  const DiamondConversionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const DiamondConversionSheet(),
    );
  }

  @override
  State<DiamondConversionSheet> createState() => _DiamondConversionSheetState();
}

class _DiamondConversionSheetState extends State<DiamondConversionSheet> {
  final TextEditingController _customGemsController = TextEditingController();
  int _selectedPresetIndex = 0;

  final List<Map<String, dynamic>> _presets = [
    {'gems': 500.0, 'coins': 5000.0, 'bonus': ''},
    {'gems': 1000.0, 'coins': 10000.0, 'bonus': ''},
    {'gems': 2500.0, 'coins': 26000.0, 'bonus': '+1,000 Bonus'},
    {'gems': 5000.0, 'coins': 55000.0, 'bonus': '+5,000 Bonus'},
    {'gems': 10000.0, 'coins': 115000.0, 'bonus': '+15,000 Bonus'},
  ];

  @override
  void dispose() {
    _customGemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final currentGems = state.profile.gemBalance;
        final selected = _presets[_selectedPresetIndex];
        final gemsToConvert = _customGemsController.text.isNotEmpty
            ? (double.tryParse(_customGemsController.text) ?? 0.0)
            : selected['gems'] as double;
        final coinsToReceive = _customGemsController.text.isNotEmpty
            ? (gemsToConvert * 10.0)
            : selected['coins'] as double;

        final canConvert = currentGems >= gemsToConvert && gemsToConvert > 0;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.dialogSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.gemCyan, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Exchange Diamonds for Coins',
                          style: AppTextStyles.titleBold.copyWith(color: Colors.white, fontSize: 17),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Available Diamonds: ${currentGems.toInt()} 💎',
                  style: const TextStyle(
                    color: AppColors.gemCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),

                // Presets Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _presets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.25,
                  ),
                  itemBuilder: (context, index) {
                    final item = _presets[index];
                    final isSel = _selectedPresetIndex == index && _customGemsController.text.isEmpty;
                    final g = (item['gems'] as double).toInt();
                    final c = (item['coins'] as double).toInt();
                    final bonus = item['bonus'] as String;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPresetIndex = index;
                          _customGemsController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.gemEmerald.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSel ? AppColors.gemCyan : Colors.white24,
                            width: isSel ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$g 💎',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '⬇',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '${c ~/ 1000}K 🪙',
                              style: const TextStyle(
                                color: AppColors.goldCoin,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                            if (bonus.isNotEmpty)
                              Text(
                                bonus,
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Custom Gems Input
                TextField(
                  controller: _customGemsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Or enter custom Diamonds amount',
                    labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
                    hintText: 'e.g. 500',
                    hintStyle: const TextStyle(color: Colors.white24),
                    suffixText: '💎',
                    suffixStyle: const TextStyle(fontSize: 16),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),

                // Conversion Summary Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Diamonds Deducted:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Text(
                            '${gemsToConvert.toInt()} 💎',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.goldCoin, size: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Coins Received:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          Text(
                            '+${coinsToReceive.toInt()} 🪙',
                            style: const TextStyle(
                              color: AppColors.goldCoin,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Convert Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canConvert ? AppColors.goldCoin : Colors.grey.shade800,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: !canConvert
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Insufficient diamonds. Earn diamonds by hosting live voice rooms!'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      : () {
                          context.read<ProfileBloc>().add(
                                ConvertGemsToCoinsEvent(
                                  gems: gemsToConvert,
                                  coins: coinsToReceive,
                                ),
                              );
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✨ Successfully converted ${gemsToConvert.toInt()} 💎 to ${coinsToReceive.toInt()} 🪙! Saved in Supabase.',
                              ),
                              backgroundColor: AppColors.gemEmerald,
                            ),
                          );
                        },
                  child: Text(
                    canConvert ? 'Confirm Exchange' : 'Insufficient Diamonds',
                    style: TextStyle(
                      color: canConvert ? Colors.black : Colors.white54,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
