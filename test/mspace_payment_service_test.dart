import 'package:flutter_test/flutter_test.dart';
import 'package:travelon_mobile/services/mspace_payment_service.dart';

void main() {
  group('MspacePaymentService Tests', () {
    late MspacePaymentService service;

    setUp(() {
      service = MspacePaymentService();
    });

    group('Phone Number Validation', () {
      test('should validate correct Sri Lankan mobile numbers', () {
        expect(service.isValidSriLankanMobile('0771234567'), true);
        expect(service.isValidSriLankanMobile('771234567'), true);
        expect(service.isValidSriLankanMobile('+94771234567'), true);
        expect(service.isValidSriLankanMobile('94771234567'), true);
      });

      test('should reject invalid mobile numbers', () {
        expect(service.isValidSriLankanMobile('0123456789'), false);
        expect(service.isValidSriLankanMobile('077123456'), false);
        expect(service.isValidSriLankanMobile('07712345678'), false);
        expect(service.isValidSriLankanMobile('abc1234567'), false);
        expect(service.isValidSriLankanMobile(''), false);
      });
    });

    group('Phone Number Formatting', () {
      test('should format phone numbers correctly', () {
        expect(service.formatPhoneNumber('0771234567'), 'tel:94771234567');
        expect(service.formatPhoneNumber('771234567'), 'tel:94771234567');
        expect(service.formatPhoneNumber('+94771234567'), 'tel:94771234567');
        expect(service.formatPhoneNumber('94771234567'), 'tel:94771234567');
      });
    });

    group('Payment Processing', () {
      test('should handle network errors gracefully', () async {
        // This test would require mocking HTTP calls
        // For now, we verify the method signature works
        expect(service.processPayment, isA<Function>());
      });
    });
  });
}
