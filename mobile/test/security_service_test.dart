import 'package:flutter_test/flutter_test.dart';
import 'package:dust_collector_mobile/services/security_service.dart';

void main() {
  test('SecurityService initialization', () {
    final service = SecurityService();
    expect(service, isNotNull);
  });
}
