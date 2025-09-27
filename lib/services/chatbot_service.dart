import 'package:cloud_firestore/cloud_firestore.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getResponse(String userMessage) async {
    String message = userMessage.toLowerCase();

    try {
      // Tour-related queries
      if (message.contains('tour') || message.contains('trip') || message.contains('event')) {
        return await _getTourInfo(message);
      }
      
      // Destination queries
      if (message.contains('place') || message.contains('destination') || 
          message.contains('sigiriya') || message.contains('ella') || 
          message.contains('kandy') || message.contains('colombo') ||
          message.contains('galle') || message.contains('location')) {
        return await _getDestinationInfo(message);
      }
      
      // Price queries
      if (message.contains('price') || message.contains('cost') || 
          message.contains('fee') || message.contains('budget')) {
        return await _getPriceInfo(message);
      }
      
      // Booking queries
      if (message.contains('book') || message.contains('reservation') || 
          message.contains('reserve')) {
        return "To make a booking:\n1. Go to the Home screen\n2. Browse available tours\n3. Select your desired tour\n4. Click 'Book Now'\n5. Fill in your details\n\nNeed help finding a specific tour? Just ask me!";
      }
      
      // Contact queries
      if (message.contains('contact') || message.contains('help') || 
          message.contains('support') || message.contains('phone') || 
          message.contains('email')) {
        return "📞 Contact Travelon Support:\n\n📧 Email: support@travelon.com\n☎️ Phone: +94 11 123 4567\n🕐 Hours: Mon-Fri, 9:00 AM - 6:00 PM\n\nYou can also visit Settings → Contact Support for more options.";
      }

      // Search for specific tour names in the database
      if (message.length > 3) {
        return await _searchSpecificTour(message);
      }

      // Default response
      return "🤖 I'm your Travelon assistant! I can help you with:\n\n• 🗺️ Tour information\n• 📍 Destination details\n• 💰 Pricing information\n• 📅 Booking assistance\n• 📞 Contact support\n\nTry asking: 'Show me tours to Sigiriya' or 'What tours are available?'";
      
    } catch (e) {
      return "I'm experiencing some technical difficulties. Please try again in a moment or contact our support team for immediate assistance.";
    }
  }

  Future<String> _getTourInfo(String message) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return "We don't have any active tours at the moment. Please check back later or contact support for upcoming tours!";
      }

      String response = "🌟 Here are our available tours:\n\n";
      int count = 1;
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String tourName = data['name'] ?? 'Unnamed Tour';
        String location = data['location'] ?? 'Various locations';
        String price = data['price']?.toString() ?? 'Contact for pricing';
        String description = data['description'] ?? 'Amazing experience awaits!';
        
        response += "$count. 🎯 $tourName\n";
        response += "   📍 $location\n";
        response += "   💰 LKR $price\n";
        response += "   ℹ️ ${description.length > 50 ? description.substring(0, 50) + '...' : description}\n\n";
        count++;
      }
      
      response += "📱 Visit the Home screen to book any of these amazing tours!";
      return response;
      
    } catch (e) {
      print('Error fetching tours: $e');
      return "I'm having trouble accessing tour information right now. Please visit the Home screen to see available tours or try again later.";
    }
  }

  Future<String> _searchSpecificTour(String message) async {
    try {
      // Search in tour names and descriptions
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .get();
      
      List<QueryDocumentSnapshot> matchingTours = [];
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = (data['name'] ?? '').toLowerCase();
        String description = (data['description'] ?? '').toLowerCase();
        String location = (data['location'] ?? '').toLowerCase();
        
        if (name.contains(message) || description.contains(message) || location.contains(message)) {
          matchingTours.add(doc);
        }
      }
      
      if (matchingTours.isEmpty) {
        return "I couldn't find any tours matching '$message'. Would you like to see all available tours instead? Just ask 'show me all tours'!";
      }
      
      String response = "🔍 Found ${matchingTours.length} tour(s) matching '$message':\n\n";
      
      for (int i = 0; i < matchingTours.length && i < 3; i++) {
        var data = matchingTours[i].data() as Map<String, dynamic>;
        String tourName = data['name'] ?? 'Unnamed Tour';
        String location = data['location'] ?? 'Location TBA';
        String price = data['price']?.toString() ?? 'Contact for pricing';
        
        response += "${i + 1}. 🎯 $tourName\n";
        response += "   📍 $location\n";
        response += "   💰 LKR $price\n\n";
      }
      
      response += "📱 Go to Home screen to book or get more details!";
      return response;
      
    } catch (e) {
      print('Error searching tours: $e');
      return "I'm having trouble searching right now. Please browse tours on the Home screen or try again later.";
    }
  }

  Future<String> _getDestinationInfo(String message) async {
    try {
      // First, try to find tours for specific destinations
      List<String> destinations = ['sigiriya', 'ella', 'kandy', 'colombo', 'galle', 'nuwara eliya', 'anuradhapura'];
      String targetDestination = '';
      
      for (String dest in destinations) {
        if (message.contains(dest)) {
          targetDestination = dest;
          break;
        }
      }
      
      if (targetDestination.isNotEmpty) {
        QuerySnapshot snapshot = await _firestore
            .collection('events')
            .where('isActive', isEqualTo: true)
            .get();
        
        List<QueryDocumentSnapshot> destinationTours = [];
        
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String location = (data['location'] ?? '').toLowerCase();
          String name = (data['name'] ?? '').toLowerCase();
          
          if (location.contains(targetDestination) || name.contains(targetDestination)) {
            destinationTours.add(doc);
          }
        }
        
        if (destinationTours.isNotEmpty) {
          String response = "🏛️ Tours available for ${targetDestination.toUpperCase()}:\n\n";
          
          for (int i = 0; i < destinationTours.length && i < 3; i++) {
            var data = destinationTours[i].data() as Map<String, dynamic>;
            response += "• ${data['name'] ?? 'Tour'} - LKR ${data['price'] ?? 'TBA'}\n";
          }
          
          response += "\n📱 Check the Home screen to book these tours!";
          return response;
        }
      }
      
      // Default destination info
      Map<String, String> destinationInfo = {
        'sigiriya': '🏛️ Sigiriya Rock Fortress - Ancient rock citadel with stunning views and rich history.',
        'ella': '🏔️ Ella - Beautiful hill station known for Nine Arch Bridge and scenic train rides.',
        'kandy': '🏛️ Kandy - Cultural capital with Temple of the Tooth and botanical gardens.',
        'colombo': '🏙️ Colombo - Vibrant capital with markets, museums, and colonial architecture.',
        'galle': '🏰 Galle - Historic Dutch fort city with beautiful coastal views.',
      };

      for (String destination in destinationInfo.keys) {
        if (message.contains(destination)) {
          return "${destinationInfo[destination]}\n\nWould you like to see available tours to this destination? Just ask 'tours to $destination'!";
        }
      }

      return "🗺️ Popular Sri Lankan destinations include:\n• Sigiriya - Ancient rock fortress\n• Ella - Hill country beauty\n• Kandy - Cultural capital\n• Colombo - Modern city life\n• Galle - Historic coastal town\n\nWhich destination interests you? Ask about tours to any of these places!";
      
    } catch (e) {
      print('Error fetching destination info: $e');
      return "I'm having trouble accessing destination information. Please try again or browse our tours on the Home screen.";
    }
  }

  Future<String> _getPriceInfo(String message) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isActive', isEqualTo: true)
          .orderBy('price')
          .get();
      
      if (snapshot.docs.isEmpty) {
        return "💰 Our tour prices typically range from LKR 3,000 to LKR 15,000 depending on the destination and duration. Contact us for specific pricing!";
      }

      List<int> prices = [];
      String response = "💰 Current tour pricing:\n\n";
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data['price'] != null) {
          int price = int.tryParse(data['price'].toString()) ?? 0;
          if (price > 0) {
            prices.add(price);
            response += "• ${data['name'] ?? 'Tour'}: LKR $price\n";
          }
        }
      }
      
      if (prices.isNotEmpty) {
        prices.sort();
        int minPrice = prices.first;
        int maxPrice = prices.last;
        response += "\n📊 Price Range: LKR $minPrice - LKR $maxPrice\n";
        response += "💡 Prices include transport and professional guide!\n";
        response += "\n📱 Visit Home screen for detailed pricing and booking!";
      } else {
        response = "💰 Please contact us for current tour pricing:\n📧 support@travelon.com\n☎️ +94 11 123 4567";
      }
      
      return response;
      
    } catch (e) {
      print('Error fetching price info: $e');
      return "I'm having trouble accessing current pricing. Please visit the Home screen for tour prices or contact our support team.";
    }
  }
}