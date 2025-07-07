import 'package:flutter/material.dart';
import '../data_model/event_model.dart';
import '../services/event_service.dart';
import '../services/cart_service.dart';
import 'event_map_screen.dart';
import 'checkout_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final Event? event;

  const EventDetailScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    this.event,
  });

  @override
  Widget build(BuildContext context) {
    final displayEvent = event;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(title, style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Add to favorites
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Share event
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Stack(
              children: [
                Image.asset(
                  imagePath,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
                if (displayEvent?.isEnded == true)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Event Ended',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),

                  // Category Badge
                  if (displayEvent != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: EventService.getCategoryColor(
                          EventService.categories
                              .firstWhere(
                                (cat) => cat.name == displayEvent.category,
                              )
                              .color,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: EventService.getCategoryColor(
                            EventService.categories
                                .firstWhere(
                                  (cat) => cat.name == displayEvent.category,
                                )
                                .color,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        displayEvent.category,
                        style: TextStyle(
                          color: EventService.getCategoryColor(
                            EventService.categories
                                .firstWhere(
                                  (cat) => cat.name == displayEvent.category,
                                )
                                .color,
                          ),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  SizedBox(height: 20),

                  // Event Details Cards
                  _buildDetailCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    content: displayEvent?.location ?? 'Location not specified',
                    color: Colors.red,
                  ),

                  if (displayEvent != null)
                    _buildDetailCard(
                      icon: Icons.calendar_today,
                      title: 'Date & Time',
                      content: _formatDate(displayEvent.date),
                      color: Colors.blue,
                    ),

                  _buildDetailCard(
                    icon: Icons.attach_money,
                    title: 'Price',
                    content: price,
                    color: Colors.green,
                  ),

                  SizedBox(height: 20),

                  // Description Section
                  Text(
                    'About This Event',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      displayEvent?.description ??
                          'This event offers a unique experience where you can engage with local culture, learn new skills, and meet new people. Don\'t miss out!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Action Buttons
                  if (displayEvent?.isEnded == true)
                    // Show ended event message
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Event Ended',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    )
                  else
                    // Show Book Now and Add to Cart buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                displayEvent != null
                                    ? () {
                                      // Direct to checkout with single item
                                      final cartService = CartService();
                                      cartService.clearCart();
                                      cartService.addToCart(displayEvent);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => CheckoutScreen(),
                                        ),
                                      );
                                    }
                                    : null,
                            child: Text(
                              'Book Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed:
                                displayEvent != null
                                    ? () {
                                      final cartService = CartService();
                                      if (cartService.isInCart(
                                        displayEvent.id,
                                      )) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${displayEvent.title} is already in cart',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      } else {
                                        cartService.addToCart(displayEvent);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              '${displayEvent.title} added to cart',
                                            ),
                                            duration: Duration(seconds: 2),
                                            action: SnackBarAction(
                                              label: 'View Cart',
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/cart',
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                    : null,
                            icon: Icon(
                              Icons.add_shopping_cart,
                              color: Colors.black,
                            ),
                            label: Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.black),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              _showContactDialog(context);
                            },
                            child: Icon(Icons.phone, color: Colors.black),
                          ),
                        ),
                      ],
                    ),

                  SizedBox(height: 16),

                  // View on Map Button
                  if (displayEvent != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      EventMapScreen(event: displayEvent),
                            ),
                          );
                        },
                        icon: Icon(Icons.map, color: Colors.blue),
                        label: Text(
                          'View on Map',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phone: +94 11 123 4567'),
              SizedBox(height: 8),
              Text('Email: events@travelon.lk'),
              SizedBox(height: 8),
              Text('WhatsApp: +94 77 123 4567'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
