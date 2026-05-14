import 'package:web3dart/web3dart.dart';
class SmartStrategyService {
  Future<bool> isGasOptimal(Web3Client client, String strategy) async {
    try {
      final p = await client.getGasPrice();
      final gwei = (p.getInWei / BigInt.from(10).pow(9)).toDouble();

      switch (strategy) {
        case 'Patient': return gwei <= 20.0;
        case 'Aggressive': return true;
        case 'Normal':
        default:
          return gwei <= 50.0;
      }
    } catch (_) { return true; }
  }
}
