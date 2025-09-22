import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class BlockchainService {
  static String rpcUrl = 'http://172.18.230.189:42654'; // Default to computer's IP for mobile access

  static Web3Client _client = Web3Client(rpcUrl, http.Client());

  static void configure({required String rpc}) {
    rpcUrl = rpc;
    _client = Web3Client(rpcUrl, http.Client());
  }

  static Web3Client get client => _client;

  static Future<EtherAmount> getBalance(EthereumAddress address) async {
    try {
      print('🔍 Checking balance for: ${address.hexEip55}');
      print('🔗 Using RPC: $rpcUrl');
      final balance = await _client.getBalance(address);
      print('💰 Balance: ${balance.getValueInUnit(EtherUnit.ether)} ETH');
      return balance;
    } catch (e) {
      print('❌ Failed to get balance: $e');
      throw Exception('Failed to connect to blockchain at $rpcUrl. Error: $e');
    }
  }
  
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing connection to: $rpcUrl');
      final networkId = await _client.getNetworkId();
      final blockNumber = await _client.getBlockNumber();
      print('✅ Connection successful!');
      print('🌐 Network ID: $networkId');
      print('🔢 Latest block: $blockNumber');
      return true;
    } catch (e) {
      print('❌ Connection failed: $e');
      return false;
    }
  }

  static Future<String> sendEth({
    required EthPrivateKey credentials,
    required EthereumAddress to,
    required EtherAmount amount,
  }) async {
    try {
      print('🔗 Sending transaction to: $rpcUrl');
      final fromAddress = await credentials.extractAddress();
      print('📤 From: ${fromAddress.hex}');
      print('📥 To: ${to.hex}');
      print('💰 Amount: ${amount.getInWei} wei (${amount.getValueInUnit(EtherUnit.ether)} ETH)');
      
      // Get network ID and determine chain ID
      final networkId = await _client.getNetworkId();
      print('🌐 Network ID: $networkId');
      
      // For Ganache, try to get the correct chain ID
      int chainId;
      try {
        // Try to get chain ID from the node
        final chainIdBig = await _client.getChainId();
        chainId = chainIdBig?.toInt() ?? networkId;
      } catch (e) {
        // Fallback: Common Ganache configurations
        if (networkId == 5777) {
          chainId = 1337; // Default Ganache chain ID
        } else {
          chainId = networkId; // Use network ID as chain ID
        }
      }
      print('🔗 Chain ID: $chainId');
      
      // Get current nonce
      final nonce = await _client.getTransactionCount(fromAddress);
      print('🔢 Nonce: $nonce');
      
      // Get gas price
      final gasPrice = await _client.getGasPrice();
      print('⛽ Gas Price: ${gasPrice.getInWei} wei');
      
      // Create and sign the transaction with proper gas limit
      final transaction = Transaction(
        to: to,
        gasPrice: gasPrice,
        maxGas: 21000, // Standard ETH transfer gas limit
        nonce: nonce,
        value: amount,
      );
      
      print('🖊️ Signing transaction with chain ID: $chainId...');
      final signedTx = await _client.signTransaction(credentials, transaction, chainId: chainId);
      
      print('📡 Broadcasting signed transaction...');
      final txHash = await _client.sendRawTransaction(signedTx);
      
      print('✅ Transaction sent successfully!');
      print('📋 Transaction hash: $txHash');
      return txHash;
      
    } catch (e, stackTrace) {
      print('❌ Transaction failed: $e');
      print('📋 Stack trace: $stackTrace');
      print('🔗 RPC URL: $rpcUrl');
      
      // Provide more specific error messages
      if (e.toString().contains('insufficient funds')) {
        throw Exception('Insufficient funds for transaction. Check your ETH balance and gas fees.');
      } else if (e.toString().contains('nonce')) {
        throw Exception('Transaction nonce error. Try again in a moment.');
      } else if (e.toString().contains('gas')) {
        throw Exception('Gas estimation failed. Check gas price and limit settings.');
      } else if (e.toString().contains('connection') || e.toString().contains('XMLHttpRequest')) {
        throw Exception('Connection failed. Check if Ganache is running and accessible at $rpcUrl');
      } else {
        throw Exception('Transaction failed: ${e.toString()}');
      }
    }
  }
}