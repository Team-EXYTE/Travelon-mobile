import 'package:flutter/material.dart';
import '../data_model/event_model.dart';
import '../services/cart_service.dart';
import '../services/firebase_service.dart';
import 'event_map_screen.dart';
import 'checkout_screen.dart';
import '../widgets/safe_scrollable.dart';

class EventDetailScreen extends StatefulWidget {
  final String imagePath;
  final String title;
  final String price;
  final Event? event;
  final String? eventId; // Add eventId parameter to load from Firebase

  const EventDetailScreen({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    this.event,
    this.eventId,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;
  final FirebaseService _firebaseService = FirebaseService();
  Event? _displayEvent;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    // If event is already provided, use it as initial data
    // but always try to fetch the latest data if we have an ID
    if (widget.event != null) {
      setState(() {
        _displayEvent = widget.event;
      });
      
      // If we have an event object, also try to fetch fresh data using its ID
      if (widget.event?.id != null) {
        try {
          setState(() {
            _isLoading = true;
          });
          
          final freshEvent = await _firebaseService.getEventById(widget.event!.id);
          
          if (freshEvent != null) {
            setState(() {
              _displayEvent = freshEvent;
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        } catch (e) {
          // If fetch fails, keep using the provided event object
          setState(() {
            _isLoading = false;
          });
          debugPrint('Error refreshing event data: $e');
        }
      }
      return;
    }

    // If eventId is provided, fetch from Firebase
    if (widget.eventId != null) {
      try {
        setState(() {
          _isLoading = true;
          _error = null;
        });

        final event = await _firebaseService.getEventById(widget.eventId!);

        setState(() {
          _displayEvent = event;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = "Failed to load event: $e";
          _isLoading = false;
        });
        debugPrint('Error loading event: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> _getEventImages() {
    // First try to use the loaded event from Firebase
    if (_displayEvent != null && _displayEvent!.images.isNotEmpty) {
      return _displayEvent!.images;
    }
    // Then fall back to passed event
    else if (widget.event != null && widget.event!.images.isNotEmpty) {
      return widget.event!.images;
    }
    // Then use single image path
    else if (widget.imagePath.isNotEmpty) {
      return [widget.imagePath];
    }
    // Default fallback
    else {
      return ['assets/event1.jpeg'];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the loaded event from Firebase if available, otherwise use the provided event
    final displayEvent = _displayEvent ?? widget.event;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () {
              // TODO: Add to favorites
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Share event
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _loadEvent,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
              : SafeScrollable(
                heightFactor: 0.9,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      Stack(
                        children: [
                          SizedBox(
                            height: 300,
                            child: PageView.builder(
                              itemCount: _getEventImages().length,
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                              itemBuilder: (context, index) {
                                final imageUrl = _getEventImages()[index];
                                return imageUrl.startsWith('http')
                                    ? Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: double.infinity,
                                          height: 300,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        );
                                      },
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: double.infinity,
                                          height: 300,
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      },
                                    )
                                    : Image.asset(
                                      imageUrl,
                                      width: double.infinity,
                                      height: 300,
                                      fit: BoxFit.cover,
                                    );
                              },
                            ),
                          ),
                          // Image indicators
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                _getEventImages().length,
                                (index) {
                                  return Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          _currentImageIndex == index
                                              ? Colors.white
                                              : Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (displayEvent?.isEnded == true)
                            Positioned(
                              top: 16,
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Text(
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
                              widget.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Category Badge
                            if (displayEvent != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: FirebaseService.getCategoryColorByName(
                                    displayEvent.category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color:
                                        FirebaseService.getCategoryColorByName(
                                          displayEvent.category,
                                        ),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  displayEvent.category,
                                  style: TextStyle(
                                    color:
                                        FirebaseService.getCategoryColorByName(
                                          displayEvent.category,
                                        ),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Event Details Cards
                            _buildDetailCard(
                              icon: Icons.location_on,
                              title: 'Location',
                              content:
                                  displayEvent?.location ??
                                  'Location not specified',
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
                              content: widget.price,
                              color: Colors.green,
                            ),

                            const SizedBox(height: 20),

                            // Description Section
                            const Text(
                              'About This Event',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Text(
                                displayEvent?.description ??
                                    'This event offers a unique experience where you can engage with local culture, learn new skills, and meet new people. Don\'t miss out!',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Action Buttons
                            if (displayEvent?.isEnded == true)
                              // Show ended event message
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          displayEvent != null
                                              ? () {
                                                // Direct to checkout with single item
                                                final cartService =
                                                    CartService();
                                                cartService.clearCart();
                                                cartService.addToCart(
                                                  displayEvent,
                                                );

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            const CheckoutScreen(),
                                                  ),
                                                );
                                              }
                                              : null,
                                      child: const Text(
                                        'Book Now',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed:
                                          displayEvent != null
                                              ? () {
                                                final cartService =
                                                    CartService();
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
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  cartService.addToCart(
                                                    displayEvent,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${displayEvent.title} added to cart',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
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
                                      icon: const Icon(
                                        Icons.add_shopping_cart,
                                        color: Colors.black,
                                      ),
                                      label: const Text(
                                        'Add to Cart',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 1,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                          color: Colors.black,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        _showContactDialog(context);
                                      },
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // View on Map Button
                            if (displayEvent != null)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.blue),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EventMapScreen(
                                              event: displayEvent,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.map,
                                    color: Colors.blue,
                                  ),
                                  label: const Text(
                                    'View on Map',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
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
          title: const Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
