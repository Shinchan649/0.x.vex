import 'package:flutter_test/flutter_test.dart';
import 'package:dust_collector_mobile/services/swap_service.dart';

void main() {
  test('SwapService initialization', () {
    final service = SwapService(apiKey: 'test_key');
    expect(service, isNotNull);
  });
}
