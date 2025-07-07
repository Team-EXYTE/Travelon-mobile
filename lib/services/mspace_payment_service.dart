import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/mspace_config.dart';

class MspacePaymentService {
  /// Process payment using mspace direct debit API
  /// Returns a map with payment result information
  Future<Map<String, dynamic>> processPayment({
    required String phoneNumber,
    required double amount,
    required String customerName,
    required String customerEmail,
  }) async {
    try {
      // Generate unique external transaction ID
      final externalTrxId = _generateTransactionId();

      // Format phone number for mspace API (must be in tel:94XXXXXXXXX format)
      final formattedPhoneNumber = formatPhoneNumber(phoneNumber);

      // Prepare request payload
      final payload = {
        'applicationId': MspaceConfig.applicationId,
        'password': MspaceConfig.password,
        'externalTrxId': externalTrxId,
        'subscriberId': formattedPhoneNumber,
        'paymentInstrumentName': MspaceConfig.paymentInstrumentName,
        'amount': amount.toStringAsFixed(2),
        'currency': MspaceConfig.currency,
      };

      // Make HTTP POST request to mspace API
      final response = await http.post(
        Uri.parse('${MspaceConfig.apiBaseUrl}/caas/direct/debit'),
        headers: {
          'Content-Type': 'application/json;charset=utf-8',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Check if payment was successful
        if (responseData['statusCode'] == 'S1000') {
          return {
            'success': true,
            'transactionId': responseData['internalTrxId'],
            'referenceId': responseData['referenceId'],
            'externalTrxId': externalTrxId,
            'timestamp': responseData['timeStamp'],
            'message': responseData['statusDetail'],
          };
        } else {
          return {
            'success': false,
            'error': responseData['statusDetail'] ?? 'Payment failed',
            'errorCode': responseData['statusCode'],
          };
        }
      } else {
        return {
          'success': false,
          'error': 'HTTP Error: ${response.statusCode}',
          'httpCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Payment processing failed: ${e.toString()}',
      };
    }
  }

  /// Generate a unique transaction ID for mspace
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return 'TRX$timestamp$random';
  }

  /// Format phone number for mspace API
  /// Expects input like "0771234567" or "771234567" or "+94771234567"
  /// Returns "tel:94771234567"
  String formatPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Handle different formats
    if (cleaned.startsWith('94')) {
      // Already has country code
      return 'tel:$cleaned';
    } else if (cleaned.startsWith('0')) {
      // Remove leading 0 and add country code
      return 'tel:94${cleaned.substring(1)}';
    } else {
      // Add country code
      return 'tel:94$cleaned';
    }
  }

  /// Validate Sri Lankan mobile number format
  bool isValidSriLankanMobile(String phoneNumber) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Check if it's a valid Sri Lankan mobile number
    if (cleaned.startsWith('94')) {
      cleaned = cleaned.substring(2); // Remove country code
    } else if (cleaned.startsWith('0')) {
      cleaned = cleaned.substring(1); // Remove leading 0
    }

    // Sri Lankan mobile numbers start with 7 and have 9 digits total
    return cleaned.length == 9 && cleaned.startsWith('7');
  }
}
