import 'package:flutter/material.dart';
import '../services/wallet_service.dart';
import 'wallet_management_screen.dart';
import 'settings_screen.dart';
import 'collection_process_screen.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}
class _DashboardScreenState extends State<DashboardScreen> {
  final _ws = WalletService(); List<Map<String, dynamic>> _wallets = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final w = await _ws.getWallets(); setState(() => _wallets = w); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(title: const Text('ULTIMATE SWEEP'), backgroundColor: Colors.transparent, actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen())))]),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.auto_fix_high, size: 80, color: Colors.amber),
        Text('${_wallets.length} Wallets Active', style: const TextStyle(color: Colors.white, fontSize: 24)),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _wallets.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CollectionProcessScreen())), child: const Text('GOD MODE: SWEEP + SWAP')),
      ])),
      bottomNavigationBar: BottomAppBar(child: IconButton(icon: const Icon(Icons.wallet), onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (c) => const WalletManagementScreen())); _load(); })),
    );
  }
}
