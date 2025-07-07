/// Example usage of MspacePaymentService
///
/// This file demonstrates how to integrate and use the mspace payment service
/// in your Flutter application.

import 'package:flutter/material.dart';
import 'package:travelon_mobile/services/mspace_payment_service.dart';

class PaymentExampleWidget extends StatefulWidget {
  @override
  _PaymentExampleWidgetState createState() => _PaymentExampleWidgetState();
}

class _PaymentExampleWidgetState extends State<PaymentExampleWidget> {
  final MspacePaymentService _paymentService = MspacePaymentService();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isProcessing = false;
  String? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('mspace Payment Example')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Mobile Number (e.g., 0771234567)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount (LKR)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              child:
                  _isProcessing
                      ? CircularProgressIndicator()
                      : Text('Process Payment'),
            ),
            SizedBox(height: 16),
            if (_result != null)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_result!),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    // Validate inputs
    if (_phoneController.text.isEmpty || _amountController.text.isEmpty) {
      setState(() {
        _result = 'Please fill in all fields';
      });
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _result = 'Please enter a valid amount';
      });
      return;
    }

    // Validate phone number
    if (!_paymentService.isValidSriLankanMobile(_phoneController.text)) {
      setState(() {
        _result = 'Please enter a valid Sri Lankan mobile number';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _result = 'Processing payment...';
    });

    try {
      // Process payment
      final result = await _paymentService.processPayment(
        phoneNumber: _phoneController.text,
        amount: amount,
        customerName: 'Test Customer',
        customerEmail: 'test@example.com',
      );

      setState(() {
        _isProcessing = false;
        if (result['success'] == true) {
          _result = '''
Payment Successful!
Transaction ID: ${result['transactionId']}
Reference ID: ${result['referenceId']}
Amount: LKR ${amount.toStringAsFixed(2)}
''';
        } else {
          _result = 'Payment Failed: ${result['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

// Example of how to use the service directly in code:
class PaymentServiceExample {
  final MspacePaymentService _paymentService = MspacePaymentService();

  /// Example: Process a simple payment
  Future<void> simplePaymentExample() async {
    try {
      final result = await _paymentService.processPayment(
        phoneNumber: '0771234567',
        amount: 100.0,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
      );

      if (result['success'] == true) {
        print('Payment successful: ${result['transactionId']}');
      } else {
        print('Payment failed: ${result['error']}');
      }
    } catch (e) {
      print('Payment error: $e');
    }
  }

  /// Example: Validate phone number before payment
  Future<void> validateAndPayExample() async {
    final phoneNumber = '0771234567';

    // Validate phone number first
    if (!_paymentService.isValidSriLankanMobile(phoneNumber)) {
      print('Invalid phone number format');
      return;
    }

    // Format phone number (optional - done automatically in processPayment)
    final formattedNumber = _paymentService.formatPhoneNumber(phoneNumber);
    print('Formatted number: $formattedNumber'); // tel:94771234567

    // Process payment
    await simplePaymentExample();
  }

  /// Example: Handle different error scenarios
  Future<void> errorHandlingExample() async {
    try {
      final result = await _paymentService.processPayment(
        phoneNumber: '0771234567',
        amount: 100.0,
        customerName: 'Test User',
        customerEmail: 'test@example.com',
      );

      if (result['success'] == true) {
        // Payment successful
        final transactionId = result['transactionId'];
        final referenceId = result['referenceId'];
        print('Payment completed: $transactionId / $referenceId');

        // You might want to:
        // 1. Store transaction details in your database
        // 2. Send confirmation email/SMS to customer
        // 3. Update order status
        // 4. Navigate to success screen
      } else {
        // Payment failed - handle different error types
        final errorCode = result['errorCode'];
        final errorMessage = result['error'];

        switch (errorCode) {
          case 'E1001':
            print('Insufficient balance');
            // Show specific message to user
            break;
          case 'E1002':
            print('Invalid subscriber');
            // Ask user to check phone number
            break;
          default:
            print('Payment failed: $errorMessage');
          // Show generic error message
        }
      }
    } catch (e) {
      // Network or other errors
      print('Payment processing error: $e');
      // Show network error message to user
    }
  }
}
