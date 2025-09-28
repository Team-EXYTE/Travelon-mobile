import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../data_model/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Add card controllers
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryMonthController = TextEditingController();
  final _expiryYearController = TextEditingController();

  // Simulate a Stripe-like payment process
  Future<bool> _simulateStripePayment(BuildContext context) async {
    bool paymentSuccess = false;
    // Validate card form fields before proceeding
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isProcessing = false);
    paymentSuccess = true;
    if (paymentSuccess) {
      // Store event IDs to remove after payment
      final itemsToRemove = List.from(_cartService.items);
      for (final item in itemsToRemove) {
        await _handleSuccessfulPayment(item.event.id, item.quantity);
        _cartService.removeItem(item.event);
      }
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 72),
                  SizedBox(height: 16),
                  Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/profile');
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
    return paymentSuccess;
  }

  final CartService _cartService = CartService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Autofill card details for demo/testing
    _cardNameController.text = 'Brent Rivera';
    _cardNumberController.text = '9510 4588 0046 7432';
    _cvcController.text = '028';
    _expiryMonthController.text = '12';
    _expiryYearController.text = '2030';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _cardNameController.dispose();
    _expiryMonthController.dispose();
    _expiryYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
      ),
      body: AnimatedBuilder(
        animation: _cartService,
        builder: (context, child) {
          if (_cartService.items.isEmpty) {
            return _buildEmptyCheckout();
          }

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummary(),
                        SizedBox(height: 24),
                        _buildCustomerDetails(),
                        SizedBox(height: 24),
                        _buildPaymentMethod(),
                        // Card form removed from here, now shown in dialog
                      ],
                    ),
                  ),
                ),
                _buildBottomCheckout(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCheckout() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No items to checkout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Go Back',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          ..._cartService.items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: _buildEventImage(item.event, 50, 50),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.event.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Rs.${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs.${_cartService.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
    return SizedBox.shrink();
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/4/41/Visa_Logo.png',
                    height: 28,
                  ),
                  SizedBox(width: 4),
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png',
                    height: 28,
                  ),
                  SizedBox(width: 4),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _cardNameController,
            decoration: InputDecoration(
              labelText: 'Name on Card',
              border: OutlineInputBorder(),
            ),
            validator:
                (value) => value == null || value.isEmpty ? 'Enter name' : null,
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              labelText: 'Card Number',
              border: OutlineInputBorder(),
            ),
            validator:
                (value) =>
                    value == null || value.isEmpty ? 'Enter card number' : null,
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _cvcController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'CVC',
                    hintText: 'ex. 311',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value == null || value.isEmpty ? 'Enter CVC' : null,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _expiryMonthController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  decoration: InputDecoration(
                    labelText: 'Expiration Month',
                    hintText: 'MM',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value == null || value.isEmpty ? 'MM' : null,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _expiryYearController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Expiration Year',
                    hintText: 'YYYY',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) => value == null || value.isEmpty ? 'YYYY' : null,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomCheckout() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs.${_cartService.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed:
                  _isProcessing ? null : () => _simulateStripePayment(context),
              child:
                  _isProcessing
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Pay with Stripe',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to generate random ticket IDs
  List<String> _generateTicketIds(int count) {
    final rand = Random();
    return List.generate(
      count,
      (i) =>
          'TICKET_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(100000)}',
    );
  }

  Future<void> _storeTicketsInFirestore(
    String eventId,
    String userId,
    List<String> ticketIds,
  ) async {
    final eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(eventRef);
      final data = snapshot.data() ?? {};
      final currentTickets = (data['tickets'] ?? {}) as Map<String, dynamic>;
      final existingIds = List<String>.from(currentTickets[userId] ?? []);
      final updatedIds = [...existingIds, ...ticketIds];
      // Update the count field as well
      final currentCount = (data['count'] ?? 0) as int;
      final newCount = currentCount + ticketIds.length;
      transaction.set(eventRef, {
        'tickets': {userId: updatedIds},
        'count': newCount,
      }, SetOptions(merge: true));
    });
  }

  Future<void> _addEventToUserBookings(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = FirebaseFirestore.instance
        .collection('users-travellers')
        .doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      final data = snapshot.data() ?? {};
      final currentBookings = List<String>.from(data['bookings'] ?? []);
      if (!currentBookings.contains(eventId)) {
        final updatedBookings = [...currentBookings, eventId];
        transaction.set(userRef, {
          'bookings': updatedBookings,
        }, SetOptions(merge: true));
      }
    });
  }

  // Call this after successful payment
  Future<void> _handleSuccessfulPayment(String eventId, int ticketCount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ticketIds = _generateTicketIds(ticketCount);
    await _storeTicketsInFirestore(eventId, user.uid, ticketIds);
    await _addEventToUserBookings(eventId);
  }

  // Helper method to build an event image
  Widget _buildEventImage(Event event, double width, double height) {
    // Get the primary image path from the event
    String imagePath = event.imagePath;

    // If there are images in the list, prioritize using the first one
    if (event.images.isNotEmpty) {
      imagePath = event.images[0]; // Use first image
    }

    // Check if the image is a network image or a local asset
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
  }
}
