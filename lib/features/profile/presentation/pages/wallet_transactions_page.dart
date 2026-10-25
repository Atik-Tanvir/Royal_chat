import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/wallet_transaction.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class WalletTransactionsPage extends StatefulWidget {
  final int initialTabIndex;

  const WalletTransactionsPage({super.key, this.initialTabIndex = 0});

  @override
  State<WalletTransactionsPage> createState() => _WalletTransactionsPageState();
}

class _WalletTransactionsPageState extends State<WalletTransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'All',
    'Recharges',
    'Withdrawals',
    'Exchanges',
    'Rewards',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    context.read<ProfileBloc>().add(LoadTransactionsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wallet Records',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: const Color(0xFF64748B),
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          final txList = state.transactions;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTxList(txList),
              _buildTxList(txList.where((t) => t.type == 'recharge').toList()),
              _buildTxList(txList.where((t) => t.type == 'withdrawal').toList()),
              _buildTxList(txList.where((t) => t.type == 'conversion').toList()),
              _buildTxList(txList.where((t) => t.type == 'daily_reward').toList()),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTxList(List<WalletTransaction> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No records in this category',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(LoadTransactionsEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final tx = items[index];
          return _buildTransactionCard(tx);
        },
      ),
    );
  }

  Widget _buildTransactionCard(WalletTransaction tx) {
    IconData icon;
    Color iconBg;
    Color iconColor;
    String sign = '+';
    Color amountColor = const Color(0xFF10B981);

    if (tx.type == 'withdrawal') {
      icon = Icons.account_balance_wallet_rounded;
      iconBg = const Color(0xFFFEF2F2);
      iconColor = const Color(0xFFEF4444);
      sign = '-';
      amountColor = const Color(0xFFEF4444);
    } else if (tx.type == 'conversion') {
      icon = Icons.swap_horiz_rounded;
      iconBg = const Color(0xFFECFDF5);
      iconColor = AppColors.gemCyan;
      sign = '+';
      amountColor = AppColors.goldCoin;
    } else if (tx.type == 'daily_reward') {
      icon = Icons.card_giftcard_rounded;
      iconBg = const Color(0xFFFFFBEB);
      iconColor = const Color(0xFFF59E0B);
      sign = '+';
      amountColor = AppColors.goldCoin;
    } else {
      icon = Icons.add_circle_rounded;
      iconBg = const Color(0xFFFFFBEB);
      iconColor = AppColors.goldCoin;
      sign = '+';
      amountColor = const Color(0xFF10B981);
    }

    final currencySymbol = tx.currency == 'gem' ? '💎' : '🪙';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Type Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${tx.createdAt.month}/${tx.createdAt.day} ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: _statusBg(tx.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.status,
                        style: TextStyle(
                          color: _statusColor(tx.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${_formatNumber(tx.amount)} $currencySymbol',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              if (tx.gateway.isNotEmpty)
                Text(
                  tx.gateway,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return const Color(0xFFDCFCE7);
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'rejected':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFD97706);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatNumber(double num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    } else if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toInt().toString();
  }
}
