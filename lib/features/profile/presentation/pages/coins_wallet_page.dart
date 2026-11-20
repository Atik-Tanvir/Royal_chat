import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../leaderboard/presentation/pages/leaderboard_page.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/diamond_conversion_sheet.dart';
import 'wallet_transactions_page.dart';

class CoinsWalletPage extends StatelessWidget {
  final String currentBalance;

  const CoinsWalletPage({super.key, this.currentBalance = '161,480'});

  void _showTopUpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _TopUpBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final balanceStr = state.profile.formattedCoins;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FA),
          body: Column(
            children: [
              // Top Golden Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 8,
                  bottom: 36,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFAE19), Color(0xFFFF9100)],
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
                ),
                child: Column(
                  children: [
                    // Nav bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 24),
                          tooltip: 'Transaction Records',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalletTransactionsPage(initialTabIndex: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Balance Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          balanceStr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Top-Up Button (Floating overlapping pill)
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: GestureDetector(
                    onTap: () => _showTopUpSheet(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F9D58), Color(0xFF056434)],
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9D58).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_rounded, color: AppColors.goldCoin, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Top-up Coins Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tasks to Earn Coins Section
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    const Text(
                      'Earn & Exchange Coins',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 1. Diamond Exchange
                    _buildTaskTile(
                      iconEmoji: '💎',
                      title: 'Exchange Diamonds for Coins',
                      subtitle: 'Convert earned gems at 1💎 = 10🪙 + Bonus',
                      onTap: () {
                        DiamondConversionSheet.show(context);
                      },
                    ),

                    // 2. Top Rank Daily
                    _buildTaskTile(
                      iconEmoji: '🏆',
                      title: 'Top Rank Daily',
                      subtitle: 'Top Player Earn 18.5M 🪙',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                        );
                      },
                    ),

                    // 3. Bucket Prediction Game Challenge
                    _buildTaskTile(
                      iconEmoji: '🪣',
                      title: 'Play Bucket Spin (8-Item)',
                      subtitle: 'Win 2x Coins every 35s 🪙',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),

                    // 4. Transaction Records
                    _buildTaskTile(
                      iconEmoji: '📜',
                      title: 'Recharge & Payment History',
                      subtitle: 'View synchronized Supabase records',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WalletTransactionsPage(initialTabIndex: 0),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskTile({
    required String iconEmoji,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(iconEmoji, style: const TextStyle(fontSize: 22)),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
          trailing: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 24),
              SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

class _TopUpBottomSheet extends StatelessWidget {
  const _TopUpBottomSheet();

  void _showCheckoutDialog(BuildContext context, Map<String, dynamic> pkg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PaymentCheckoutSheet(pkg: pkg),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packages = [
      {'coins': '10,000', 'raw': 10000.0, 'bonus': '+7,500', 'price': '\$0.99'},
      {'coins': '55,000', 'raw': 55000.0, 'bonus': '+41,250', 'price': '\$4.99'},
      {'coins': '230,000', 'raw': 230000.0, 'bonus': '+172,500', 'price': '\$19.99'},
      {'coins': '600,000', 'raw': 60000.0, 'bonus': '+450,000', 'price': '\$49.99'},
      {'coins': '1,300,000', 'raw': 1300000.0, 'bonus': '+975,000', 'price': '\$99.99'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top-up Coins (+75% First Recharge)',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: packages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final pkg = packages[index];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _showCheckoutDialog(context, pkg);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            pkg['coins'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      Text(
                        pkg['bonus'] as String,
                        style: const TextStyle(color: Color(0xFFE11D48), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pkg['price'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _PaymentCheckoutSheet extends StatefulWidget {
  final Map<String, dynamic> pkg;

  const _PaymentCheckoutSheet({required this.pkg});

  @override
  State<_PaymentCheckoutSheet> createState() => _PaymentCheckoutSheetState();
}

class _PaymentCheckoutSheetState extends State<_PaymentCheckoutSheet> {
  String _selectedCountry = 'BD'; // 'BD' or 'IN'
  String _selectedMethod = 'bKash';
  bool _isProcessing = false;
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _trxIdController = TextEditingController();

  @override
  void dispose() {
    _senderController.dispose();
    _trxIdController.dispose();
    super.dispose();
  }

  final Map<String, List<Map<String, String>>> _countryMethods = {
    'BD': [
      {
        'name': 'bKash',
        'icon': '📱',
        'desc': 'Send Money to Admin Personal',
        'adminNumber': '01812345678',
      },
      {
        'name': 'Nagad',
        'icon': '⚡',
        'desc': 'Send Money to Admin Personal',
        'adminNumber': '01912345678',
      },
    ],
    'IN': [
      {
        'name': 'Google Pay',
        'icon': '💳',
        'desc': 'Instant GPay / UPI Transfer',
        'adminNumber': 'gamegala.pay@oksbi',
      },
      {
        'name': 'Paytm',
        'icon': '💰',
        'desc': 'Paytm Wallet or UPI Transfer',
        'adminNumber': 'gamegala.pay@paytm',
      },
      {
        'name': 'PhonePe',
        'icon': '🟣',
        'desc': 'PhonePe UPI Direct Transfer',
        'adminNumber': 'gamegala.pay@ybl',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final coins = widget.pkg['coins'] as String;
    final bonus = widget.pkg['bonus'] as String;
    final price = widget.pkg['price'] as String;
    final rawAmount = widget.pkg['raw'] as double;
    final methods = _countryMethods[_selectedCountry]!;
    final selectedMethodData = methods.firstWhere(
      (m) => m['name'] == _selectedMethod,
      orElse: () => methods.first,
    );

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 22,
          right: 22,
          top: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 22,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top-up Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Package Details Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.goldCoin.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: AppColors.goldCoin, size: 28),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$coins Coins',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            bonus,
                            style: const TextStyle(color: Color(0xFFE11D48), fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Country Selector Tab
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCountry = 'BD';
                        _selectedMethod = 'bKash';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedCountry == 'BD' ? const Color(0xFF16A34A).withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedCountry == 'BD' ? const Color(0xFF16A34A) : Colors.grey.shade300,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🇧🇩 Bangladesh',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCountry = 'IN';
                        _selectedMethod = 'Google Pay';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedCountry == 'IN' ? const Color(0xFF16A34A).withValues(alpha: 0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedCountry == 'IN' ? const Color(0xFF16A34A) : Colors.grey.shade300,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '🇮🇳 India',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment Methods List
            ...List.generate(methods.length, (i) {
              final m = methods[i];
              final isSel = _selectedMethod == m['name'];

              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = m['name']!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSel ? const Color(0xFF16A34A) : Colors.grey.shade200,
                      width: isSel ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(m['icon']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['name']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              m['desc']!,
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (isSel)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),

            // Official Admin Recipient Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send $price to Official Admin $_selectedMethod:',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedMethodData['adminNumber'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    icon: const Icon(Icons.copy_rounded, size: 14),
                    label: const Text('Copy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final numToCopy = selectedMethodData['adminNumber'] ?? '';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copied $numToCopy to clipboard!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Sender Phone / UPI
            TextField(
              controller: _senderController,
              decoration: InputDecoration(
                labelText: _selectedCountry == 'BD'
                    ? 'Your Sender $_selectedMethod Number (11 digits)'
                    : 'Your Sender Phone / UPI ID',
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                hintText: _selectedCountry == 'BD' ? '01XXXXXXXXX' : '9876543210 or yourname@upi',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),

            // Transaction ID
            TextField(
              controller: _trxIdController,
              decoration: InputDecoration(
                labelText: 'Transaction ID / Reference (TrxID)',
                labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                hintText: 'e.g. 9J87AK29 or UPI Ref number',
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            // Pay Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
              onPressed: _isProcessing
                  ? null
                  : () async {
                      final sender = _senderController.text.trim();
                      final trxId = _trxIdController.text.trim();

                      if (sender.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter your sender mobile number or UPI ID'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      if (trxId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter payment Transaction ID (TrxID)'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      setState(() => _isProcessing = true);
                      await Future.delayed(const Duration(milliseconds: 600));

                      if (!context.mounted) return;

                      final countryLabel = _selectedCountry == 'BD' ? '🇧🇩 BD' : '🇮🇳 IN';
                      context.read<ProfileBloc>().add(
                            RechargeCoinsEvent(
                              rawAmount,
                              gateway: '$_selectedMethod ($countryLabel - Sender: $sender, Trx: $trxId)',
                              packageTitle: 'Top-up $coins Coins ($price)',
                            ),
                          );

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✨ Top-up submitted! Recharged $coins coins via $_selectedMethod.'),
                          backgroundColor: AppColors.gemEmerald,
                          action: SnackBarAction(
                            label: 'View History',
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const WalletTransactionsPage(initialTabIndex: 1),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
              child: _isProcessing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Confirm Payment & Add $coins Coins',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
