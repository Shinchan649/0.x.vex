import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});
  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}
class _WalletManagementScreenState extends State<WalletManagementScreen> {
  final WalletService _walletService = WalletService();
  List<Map<String, dynamic>> _wallets = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final w = await _walletService.getWallets(); setState(() { _wallets = w; }); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0F0F1A), appBar: AppBar(title: const Text('Wallets')), body: ListView.builder(itemCount: _wallets.length, itemBuilder: (c, i) => ListTile(title: Text(_wallets[i]['name'], style: const TextStyle(color: Colors.white)), subtitle: Text(_wallets[i]['address'], style: const TextStyle(color: Colors.white54)))), floatingActionButton: FloatingActionButton(onPressed: () async { final m = await _walletService.createNewMnemonic(); final k = await _walletService.derivePrivateKey(m); await _walletService.saveWallet('HD Wallet', k, mnemonic: m); _load(); }, child: const Icon(Icons.add)));
  }
}
