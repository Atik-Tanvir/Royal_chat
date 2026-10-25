import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/supabase_config.dart';
import '../../features/profile/domain/entities/wallet_transaction.dart';

class WalletTransactionService {
  static const String _storagePrefix = 'royal_wallet_tx_';

  /// Save a new transaction locally
  static Future<void> recordTransaction(WalletTransaction tx) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix${tx.userId}';
      final existingRaw = prefs.getStringList(key) ?? [];

      existingRaw.insert(0, jsonEncode(tx.toJson()));
      // Cap at 100 recent transactions
      if (existingRaw.length > 100) {
        existingRaw.removeRange(100, existingRaw.length);
      }
      await prefs.setStringList(key, existingRaw);
    } catch (e) {
      debugPrint('[WalletTransactionService] Error recording transaction: $e');
    }
  }

  /// Retrieve all transactions, combining local records with live Supabase withdrawals
  static Future<List<WalletTransaction>> getTransactions(String userId) async {
    final List<WalletTransaction> allTx = [];

    // 1. Fetch live withdrawals from Supabase for this user
    try {
      final res = await SupabaseConfig.client
          .from('withdrawals')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      for (final item in res) {
        final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final gems = (item['gems'] as num?)?.toDouble() ?? (amt * 1000);
        final status = item['status']?.toString() ?? 'Pending';
        final gateway = item['gateway']?.toString() ?? 'bKash';
        final createdAt = item['created_at'] != null
            ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
            : DateTime.now();

        allTx.add(
          WalletTransaction(
            id: item['id']?.toString() ?? 'WD-${DateTime.now().millisecondsSinceEpoch}',
            userId: userId,
            type: 'withdrawal',
            title: 'Withdrawal to $gateway',
            amount: gems,
            currency: 'gem',
            status: status,
            gateway: gateway,
            createdAt: createdAt,
          ),
        );
      }
    } catch (e) {
      debugPrint('[WalletTransactionService] Supabase withdrawals fetch error: $e');
    }

    // 2. Fetch local records (recharges, conversions, gifts, daily rewards)
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_storagePrefix$userId';
      final rawList = prefs.getStringList(key) ?? [];

      for (final raw in rawList) {
        try {
          final map = jsonDecode(raw) as Map<String, dynamic>;
          final tx = WalletTransaction.fromJson(map);
          // Avoid duplicate withdrawals already added from Supabase
          if (tx.type != 'withdrawal' || !allTx.any((e) => e.id == tx.id)) {
            allTx.add(tx);
          }
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[WalletTransactionService] Local transactions fetch error: $e');
    }

    // 3. Sort chronologically descending
    allTx.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allTx;
  }
}
