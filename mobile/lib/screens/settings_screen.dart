import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  final _r = TextEditingController();
  final _d = TextEditingController();
  final _a = TextEditingController();
  String _c = 'Polygon';
  String _strategy = 'Normal';
  bool _swapToStable = false;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _r.text = p.getString('rpcUrl') ?? '';
      _d.text = p.getString('destinationAddress') ?? '';
      _a.text = p.getString('oneInchApiKey') ?? '';
      _c = p.getString('chainName') ?? 'Polygon';
      _strategy = p.getString('gasStrategy') ?? 'Normal';
      _swapToStable = p.getBool('swapToStable') ?? false;
    });
  }
  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('rpcUrl', _r.text);
    await p.setString('destinationAddress', _d.text);
    await p.setString('oneInchApiKey', _a.text);
    await p.setString('chainName', _c);
    await p.setString('gasStrategy', _strategy);
    await p.setBool('swapToStable', _swapToStable);
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _r, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'RPC URL')),
          TextField(controller: _d, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: 'Payout Address')),
          TextField(controller: _a, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: '1inch API Key (Optional)')),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Chain: ', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                value: _c,
                dropdownColor: const Color(0xFF1E1E2E),
                style: const TextStyle(color: Colors.white),
                items: ['Ethereum', 'Polygon', 'BSC'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _c = v!)
              ),
            ],
          ),
          Row(
            children: [
              const Text('Gas Strategy: ', style: TextStyle(color: Colors.white)),
              DropdownButton<String>(
                value: _strategy,
                dropdownColor: const Color(0xFF1E1E2E),
                style: const TextStyle(color: Colors.white),
                items: ['Patient', 'Normal', 'Aggressive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _strategy = v!)
              ),
            ],
          ),
          SwitchListTile(
            title: const Text('Swap Dust to Stablecoins', style: TextStyle(color: Colors.white)),
            value: _swapToStable,
            onChanged: (v) => setState(() => _swapToStable = v),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text('Save'))
        ]
      )
    );
  }
}
