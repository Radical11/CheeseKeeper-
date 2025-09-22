import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import 'blockchain_service.dart';

class TransactionService {
  static const _kStorageKey = 'tx_history';

  static Future<List<WalletTransaction>> list() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw == null) return [];
    final List<dynamic> arr = json.decode(raw);
    return arr.map((e) => WalletTransaction.fromMap(e as Map<String, dynamic>)).toList();
  }

  static Future<void> add(WalletTransaction tx) async {
    final listTx = await list();
    listTx.insert(0, tx);
    await _save(listTx);
  }

  static Future<void> updateStatus(String hash, String status) async {
    final listTx = await list();
    for (var i = 0; i < listTx.length; i++) {
      if (listTx[i].hash.toLowerCase() == hash.toLowerCase()) {
        listTx[i] = listTx[i].copyWith(status: status);
        break;
      }
    }
    await _save(listTx);
  }

  static Future<void> _save(List<WalletTransaction> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final arr = txs.map((e) => e.toMap()).toList();
    await prefs.setString(_kStorageKey, json.encode(arr));
  }

  // Refresh statuses by querying the chain for receipts.
  static Future<void> refreshStatuses() async {
    final client = BlockchainService.client;
    final listTx = await list();
    for (final tx in listTx) {
      final receipt = await client.getTransactionReceipt(tx.hash);
      String newStatus;
      if (receipt == null) {
        newStatus = 'Pending';
      } else if (receipt.status ?? false) {
        newStatus = 'Success';
      } else {
        newStatus = 'Failed';
      }
      await updateStatus(tx.hash, newStatus);
    }
  }
}