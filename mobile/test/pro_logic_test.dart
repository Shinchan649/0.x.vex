import 'package:flutter_test/flutter_test.dart';
import 'package:dust_collector_mobile/services/collector_service.dart';
import 'package:dust_collector_mobile/services/wallet_service.dart';
void main() {
  group('Logic Tests', () {
    final ws = WalletService();
    test('mnemonic', () async { expect((await ws.createNewMnemonic()).split(' ').length, 12); });
    test('collector', () async { expect(await CollectorService().collectDust(rpcUrl: '', privateKeys: [], destinationAddress: ''), isEmpty); });
  });
}
