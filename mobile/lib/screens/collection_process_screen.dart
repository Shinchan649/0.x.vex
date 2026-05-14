import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/collector_service.dart';
import '../services/wallet_service.dart';
import '../services/smart_strategy_service.dart';
import '../services/swap_service.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
class CollectionProcessScreen extends StatefulWidget {
  const CollectionProcessScreen({super.key});
  @override
  State<CollectionProcessScreen> createState() => _CollectionProcessScreenState();
}
class _CollectionProcessScreenState extends State<CollectionProcessScreen> {
  final _c = CollectorService(); final _w = WalletService(); final _s = SmartStrategyService(); final _sw = SwapService(); List<String> _logs = []; bool _loading = false;
  @override
  void initState() { super.initState(); _run(); }
  Future<void> _run() async {
    setState(() => _loading = true);
    try {
      final p = await SharedPreferences.getInstance();
      final rpc = p.getString('rpcUrl') ?? '';
      final dest = p.getString('destinationAddress') ?? '';
      final chain = p.getString('chainName') ?? 'Polygon';
      final strategy = p.getString('gasStrategy') ?? 'Normal';
      final swapToStable = p.getBool('swapToStable') ?? false;
      final apiKey = p.getString('oneInchApiKey');

      final client = Web3Client(rpc, Client());
      setState(() => _logs.add('Analyzing Network Strategy ($strategy)...'));

      final isOptimal = await _s.isGasOptimal(client, strategy);
      if (!isOptimal) {
        setState(() => _logs.add('Gas prices too high for $strategy strategy. Waiting...'));
        // In a real app we might loop/wait, for now we proceed or abort
      }

      final wallets = await _w.getWallets();
      for (var w in wallets) {
        setState(() => _logs.add('Targeting Wallet ${w['address']}...'));
        final k = await _w.getPrivateKey(w['address']); if (k == null) continue;
        final res = await _c.collectDust(
          rpcUrl: rpc,
          privateKeys: [k],
          destinationAddress: dest,
          chainName: chain,
          swapToStable: swapToStable,
          oneInchApiKey: apiKey,
        );
        for (var r in res) setState(() => _logs.add('${r['type']}: ${r['status']} (${r['amount']})'));
      }
      setState(() => _logs.add('GOD SWEEP COMPLETE.'));
      await client.dispose();
    } catch (e) { setState(() => _logs.add('Error: $e')); } finally { setState(() => _loading = false); }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0F0F1A), appBar: AppBar(title: const Text('God Sweep')), body: Column(children: [if (_loading) const LinearProgressIndicator(), Expanded(child: ListView.builder(itemCount: _logs.length, itemBuilder: (c, i) => ListTile(title: Text(_logs[i], style: const TextStyle(color: Colors.white, fontSize: 12))))) ]));
  }
}
