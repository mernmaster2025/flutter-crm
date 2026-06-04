import 'package:flutter_crm/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators', () {
    test('accepts valid email addresses', () {
      expect(Validators.email('maya@apexcrm.dev'), isNull);
    });

    test('rejects invalid email addresses', () {
      expect(Validators.email('maya'), isNotNull);
    });

    test('requires strong enough passwords', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('password123'), isNull);
    });
  });
}
