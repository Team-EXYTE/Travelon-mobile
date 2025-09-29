import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatbotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final GenerativeModel _model;
  
  ChatbotService() {
    try {
      // Use the API key from the .env file
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        print('Failed to load GEMINI_API_KEY from .env file');
        return;
      }
      _model = GenerativeModel(
        model: 'gemini-2.5-pro', // Using the more powerful model
        apiKey: apiKey,
      );
    } catch (e) {
      print('Failed to initialize Gemini AI: $e');
    }
  }

  Future<String> getResponse(String userMessage) async {
    String message = userMessage.toLowerCase();

    // First check if the query is related to Sri Lankan tourism
    if (!_isTourismRelated(message)) {
      return "That seems to be outside my scope. I'm a travel assistant for Sri Lanka! \n\nPlease ask me about:\n• 🗺️ Tours and events\n• 📍 Destinations\n• 💰 Tour pricing\n• 📅 Booking information";
    }
    try {
      // Step 1: Try database first for specific data
      String? dbResult = await _tryDatabaseFirst(message);
      if (dbResult != null) {
        return dbResult;
      }

      // Step 2: If no database answer, use Gemini AI
      return await _getGeminiResponse(userMessage);
      
    } catch (e) {
      print('Chatbot error: $e');
      return "I'm experiencing some technical difficulties. Please try again in a moment or contact our support team for immediate assistance.";
    }
  }

  // Try to find answers in database first
  Future<String?> _tryDatabaseFirst(String message) async {
    try {
      // NEW: Check for user interests first
      if (message.contains('like') || message.contains('enjoy') || message.contains('interested in')) {
        String? interestResult = await _recommendEventByInterest(message);
        if (interestResult != null) return interestResult;
      }

      // Specific event details queries
      if (message.contains('tell me more about') || message.contains('details about') || 
          message.contains('more info about') || message.contains('tell more about')) {
        return await _getSpecificEventDetails(message);
      }
      
      // Tour-related queries
      if (message.contains('tour') || message.contains('trip') || message.contains('upcoming events')) {
        return await _getTourInfo(message, false);
      }
      
      // Event-related queries
      if (message.contains('event')) {
        if (message.contains('ended') || message.contains('past') || message.contains('finished')) {
          return await _getTourInfo(message, true);
        } else {
          // FIXED: Default to showing upcoming events, not all
          return await _getTourInfo(message, false);
        }
      }
      
      // Price queries - always from database
      if (message.contains('price') || message.contains('cost') || 
          message.contains('fee') || message.contains('budget')) {
        return await _getPriceInfo();
      }
      
      // Booking queries
      if (message.contains('book') || message.contains('reservation') || 
          message.contains('reserve')) {
        return "📅 To make a booking:\n\n1. Go to the Home screen\n2. Browse available tours\n3. Select your desired tour\n4. Click 'Book Now'\n5. Fill in your details\n\n💡 Need help finding a specific tour? Just ask me about destinations like Sigiriya, Ella, or Kandy!";
      }
      
      // Contact queries
      if (message.contains('contact') || message.contains('help') || 
          message.contains('support') || message.contains('phone') || 
          message.contains('email')) {
        return "Contact Travelon Support:\n\n📧 Email: support@travelon.com\n☎️ Phone: +94 11 123 4567\n🕒 Hours: Mon-Fri, 9:00 AM - 6:00 PM\n\nYou can also visit Settings → Contact Support for more options.";
      }
      
      // Search for specific tour names
      List<String> messageWords = message.split(' ').where((word) => word.length > 2).toList();
      if (messageWords.isNotEmpty) {
        String? specificTour = await _searchSpecificTour(message);
        if (specificTour != null && !specificTour.contains('No Sri Lankan tours found')) {
          return specificTour;
        }
      }

      return null; // No database answer found
      
    } catch (e) {
      print('Database search error: $e');
      return null;
    }
  }

  // NEW: Recommend events based on user's stated interests
  Future<String?> _recommendEventByInterest(String message) async {
    String interest = '';
    RegExpMatch? match;

    // Extract the word/phrase after the interest keyword
    if (message.contains('like ')) {
      match = RegExp(r'like ([\w\s]+)').firstMatch(message);
    } else if (message.contains('enjoy ')) {
      match = RegExp(r'enjoy ([\w\s]+)').firstMatch(message);
    } else if (message.contains('interested in ')) {
      match = RegExp(r'interested in ([\w\s]+)').firstMatch(message);
    }

    if (match != null) {
      interest = match.group(1)!.trim().replaceAll(RegExp(r'[.!?]$'), '');
    }

    if (interest.isEmpty) return null;

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isEnded', isEqualTo: false)
          .get();

      List<QueryDocumentSnapshot> matchingEvents = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = (data['name'] ?? '').toLowerCase();
        String description = (data['description'] ?? '').toLowerCase();
        
        // Check if the interest is mentioned in the name or description
        if (name.contains(interest) || description.contains(interest)) {
          matchingEvents.add(doc);
        }
      }

      if (matchingEvents.isNotEmpty) {
        String response = "That's great! Since you like $interest, you might be interested in this:\n\n";
        var eventData = matchingEvents.first.data() as Map<String, dynamic>;
        response += "✨ ${eventData['name'] ?? 'Event'}\n";
        response += "📍 Location: ${eventData['location'] ?? 'TBA'}\n";
        response += "💰 Price: LKR ${_safeToString(eventData['price'], 'TBA')}\n\n";
        response += "Would you like to know more about this event?";
        return response;
      }

      return null; // No matching event found, let Gemini handle it
    } catch (e) {
      print("Error recommending event by interest: $e");
      return null;
    }
  }

  // Use Gemini AI for questions not answered by database
  Future<String> _getGeminiResponse(String userMessage) async {
    try {
      // Get database context to provide to AI
      String dbContext = await _getDatabaseContext();
      
      String prompt = """
You are a Sri Lankan tourism assistant for Travelon travel company.

STRICT RULES:
1. ONLY answer questions about Sri Lankan tourism, travel, destinations, culture, and attractions.
2. If asked about non-tourism topics, respond with: "That seems to be outside my scope. I'm a travel assistant for Sri Lanka! \n\nPlease ask me about:\n• 🗺️ Tours and events\n• 📍 Destinations\n• 💰 Tour pricing\n• 📅 Booking information"
3. Provide practical, helpful information about traveling in Sri Lanka.
4. Include transportation options, best times to visit, what to see, etc.
5. Keep responses concise but informative.
6. Use a few relevant emojis to make the response engaging, but not too many.
7. Use this database context when relevant: $dbContext

CURRENT DATABASE TOURS: $dbContext

User question: $userMessage
""";

      final response = await _model.generateContent([Content.text(prompt)]);
      String aiResponse = response.text ?? "I can help you with Sri Lankan tourism questions. What would you like to know?";
      
      return aiResponse;
      
    } catch (e) {
      print('Gemini AI error: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  // Get database context for AI
  Future<String> _getDatabaseContext() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isEnded', isEqualTo: false) // Only provide active events as context
          .limit(5)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return "No current tours in database.";
      }
      
      String context = "Available tours: ";
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = data['name'] ?? 'Tour';
        String location = data['location'] ?? '';
        String price = data['price']?.toString() ?? '';
        
        context += "$name at $location - LKR $price; ";
      }
      return context;
    } catch (e) {
      return "Database unavailable";
    }
  }

  // Fallback response when AI fails
  String _getFallbackResponse(String message) {
    if (message.contains('how to go') || message.contains('how to get') || message.contains('transport')) {
      return "Transportation in Sri Lanka:\n\n• 🚌 Bus: Cheapest option, extensive network\n• 🚂 Train: Scenic routes, especially to hill country\n• 🛺 Taxi/Tuk-tuk: Convenient for short distances\n• 🚐 Private hire: Best for multiple destinations\n\nFor specific routes, check local transport or ask our tour guides when booking!";
    }
    
    if (message.contains('best time') || message.contains('when to visit')) {
      return "Best time to visit Sri Lanka:\n\n• Dec-Mar: West & South coasts (dry season)\n• Apr-Sep: East coast & cultural triangle\n• Hill country: Year-round, cooler temperatures\n\nAvoid heavy monsoon periods for your preferred region!";
    }
    
    return "I can help with Sri Lankan tourism questions like:\n\n• How to get to destinations\n• Best times to visit\n• What to see and do\n• Transportation options\n• Cultural information\n\nWhat would you like to know about traveling in Sri Lanka?";
  }

  // Check if the message is related to Sri Lankan tourism
  bool _isTourismRelated(String message) {
  List<String> tourismKeywords = [
    // Greetings
    'hi', 'hello', 'hey', 'good morning', 'good afternoon', 'good evening',
    
    // Sri Lankan places
    'sri lanka', 'sigiriya', 'ella', 'kandy', 'colombo', 'galle', 'anuradhapura',
    'nuwara eliya', 'bentota', 'hikkaduwa', 'polonnaruwa', 'dambulla', 
    'trincomalee', 'mirissa', 'arugam bay', 'jaffna', 'matara', 'badulla', 
    'ratnapura', 'kalutara', 'ambalangoda', 'hambantota', 'udawalawe', 'wilpattu',
    
    // Tourism related words
    'tour', 'trip', 'travel', 'event', 'destination', 'place', 'visit',
    'book', 'booking', 'reservation', 'price', 'cost', 'temple', 'beach',
    'mountain', 'culture', 'festival', 'hotel', 'guide', 'sightseeing',
    'transport', 'bus', 'train', 'taxi', 'flight', 'airport', 'package',
    'holiday', 'vacation', 'stay', 'guesthouse', 'resort', 'heritage',
    'adventure', 'eco', 'camping', 'hiking', 'wildlife', 'park', 'safari',
    'museum', 'city tour', 'cultural show', 'cooking class', 'surfing', 'diving',
    'snorkeling', 'whale watching', 'rafting', 'trekking', 'temple visit',
    
    // Interest / experience words
    'like', 'enjoy', 'interested', 'cooking', 'hiking', 'history',
    'culture', 'shopping', 'market', 'local food', 'restaurants', 'ayurveda', 
    'spa', 'massage', 'relax', 'beaches', 'mountains', 'villages', 'tea plantations',
    
    // General service / question words
    'help', 'support', 'contact', 'info', 'information', 'available',
    'what', 'where', 'when', 'how', 'tell', 'show', 'about', 'recommend',
    'suggest', 'find', 'nearby', 'around', 'near'
  ];

  for (String keyword in tourismKeywords) {
    if (message.contains(keyword)) {
      return true;
    }
  }
  return false;
}

  // Handle specific event detail requests
  Future<String> _getSpecificEventDetails(String message) async {
    try {
      // Extract the event name from the message
      String eventQuery = message.replaceAll(RegExp(r'(tell me more about|details about|more info about|tell more about)'), '').trim();
      
      if (eventQuery.isEmpty) {
        return "Please specify which event you'd like to know more about. For example:\n- 'Tell me more about Sigiriya tour'\n- 'Details about Kandy cultural event'";
      }

      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .get();
      
      List<QueryDocumentSnapshot> matchingEvents = [];
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = (data['name'] ?? data['title'] ?? '').toLowerCase();
        String location = (data['location'] ?? data['venue'] ?? '').toLowerCase();
        
        // Check if the event query matches the event name, location
        if (name.contains(eventQuery) || location.contains(eventQuery) || 
            eventQuery.split(' ').any((word) => word.length > 2 && (name.contains(word) || location.contains(word)))) {
          matchingEvents.add(doc);
        }
      }
      
      if (matchingEvents.isEmpty) {
        return "I couldn't find any events matching '$eventQuery'.\n\n💡 Try asking about:\n• Specific destinations (Sigiriya, Ella, Kandy)\n• Tour types (cultural tour, hiking trip)\n• Or ask 'show me all tours' to see available options";
      }
      
      if (matchingEvents.length == 1) {
        // Return detailed info for single match
        var data = matchingEvents.first.data() as Map<String, dynamic>;
        return _formatEventDetails(data);
      } else {
        // Multiple matches - show list to choose from
        String response = "I found ${matchingEvents.length} events matching '$eventQuery':\n\n";
        
        for (int i = 0; i < matchingEvents.length && i < 3; i++) {
          var data = matchingEvents[i].data() as Map<String, dynamic>;
          String name = data['name'] ?? data['title'] ?? 'Unnamed Event';
          String location = data['location'] ?? 'Location TBA';
          bool isEnded = data['isEnded'] ?? false;
          
          response += "${i + 1}. $name\n";
          response += "   📍 Location: $location\n";
          response += "   📊 Status: ${isEnded ? 'Ended' : 'Available'}\n\n";
        }
        
        response += "Please be more specific about which event you'd like details for!";
        return response;
      }
      
    } catch (e) {
      print('Error getting specific event details: $e');
      return "I'm having trouble accessing event details right now. Please try again or browse events on the Home screen.";
    }
  }

  // Format detailed event information
  String _formatEventDetails(Map<String, dynamic> data) {
    String name = data['name'] ?? data['title'] ?? 'Unnamed Event';
    String location = data['location'] ?? data['venue'] ?? 'Location TBA';
    String description = data['description'] ?? data['details'] ?? 'No description available';
    String price = _safeToString(data['price'] ?? data['cost'], 'Contact for pricing');
    String address = data['address'] ?? 'Address not specified';
    bool isEnded = data['isEnded'] ?? false;
    
    String response = "✨ EVENT DETAILS: $name ✨\n\n";
    response += "📍 Location: $location\n";
    response += "🗺️ Address: $address\n";
    response += "💰 Price: LKR $price\n";
    response += "📊 Status: ${isEnded ? 'Event Ended' : 'Available for Booking'}\n\n";
    response += "📝 Description:\n$description\n\n";
    
    if (data['date'] != null) {
      response += "📅 Date: ${_formatDate(data['date'])}\n";
    }
    if (data['duration'] != null) {
      response += "🕒 Duration: ${_safeToString(data['duration'], 'Duration TBA')}\n";
    }
    if (data['maxParticipants'] != null) {
      response += "👥 Max Participants: ${_safeToString(data['maxParticipants'], 'Contact for info')}\n";
    }
    
    if (!isEnded) {
      response += "\n📲 Book Now: Go to Home screen → Find this event → Click 'Book Now'\n\n";
    }
    
    response += "📞 Need more help? Contact support at +94 11 123 4567";
    
    return response;
  }

  String _formatDate(dynamic date) {
    try {
      if (date is Timestamp) {
        DateTime dt = date.toDate();
        return '${dt.day}/${dt.month}/${dt.year}';
      }
      return date.toString();
    } catch (e) {
      return 'Date TBA';
    }
  }

  String _safeToString(dynamic value, String defaultValue) {
    try {
      if (value == null) return defaultValue;
      if (value is Timestamp) {
        return _formatDate(value);
      }
      return value.toString();
    } catch (e) {
      return defaultValue;
    }
  }

  Future<String> _getTourInfo(String message, bool? showEnded) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .limit(15)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return "We don't have any events in our database at the moment. Please check back later or contact support!";
      }

      List<QueryDocumentSnapshot> filteredEvents = [];
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        bool isEnded = data['isEnded'] ?? false;
        
        if (showEnded == null) { // If null, show all
          filteredEvents.add(doc);
        } else if (showEnded == true && isEnded) { // If true, show only ended
          filteredEvents.add(doc);
        } else if (showEnded == false && !isEnded) { // If false, show only active
          filteredEvents.add(doc);
        }
      }

      if (filteredEvents.isEmpty) {
        if (showEnded == true) {
          return "📅 No ended events found at the moment.";
        } else if (showEnded == false) {
          return "No active tours available at the moment. Please check back later!";
        } else {
          return "No events found in our database.";
        }
      }

      String title = showEnded == true ? "📅 Recently Ended Events:" : 
                    showEnded == false ? "🚀 Available Sri Lankan Tours & Events:" : "All Sri Lankan Events:";
      
      String response = "$title\n\n";
      int count = 1;
      
      for (var doc in filteredEvents) {
        var data = doc.data() as Map<String, dynamic>;
        
        String tourName = data['name'] ?? data['title'] ?? 'Unnamed Event';
        String location = data['location'] ?? 'Location TBA';
        String price = _safeToString(data['price'], 'Contact for pricing');
        bool isEnded = data['isEnded'] ?? false;
        String status = isEnded ? "Ended" : "Available";
        
        response += "$count. $tourName\n";
        response += "   📍 Location: $location\n";
        response += "   💰 Price: LKR $price\n";
        response += "   📊 Status: $status\n\n";
        count++;
        
        if (count > 6) break;
      }
      
      if (showEnded == false) {
        response += "📲 Visit the Home screen to book these amazing Sri Lankan tours!";
      } else if (showEnded == true) {
        response += "These events have ended, but we might have similar upcoming tours!";
      } else {
        response += "Visit the Home screen for active bookings!";
      }
      
      return response;
      
    } catch (e) {
      print('Error fetching tours: $e');
      return "I'm having trouble accessing tour information right now. Please visit the Home screen or try again later.";
    }
  }

  Future<String?> _searchSpecificTour(String message) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .get();
      
      List<QueryDocumentSnapshot> matchingTours = [];
      List<String> messageWords = message.split(' ').where((word) => word.length > 2).toList();
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String name = (data['name'] ?? data['title'] ?? '').toLowerCase();
        String location = (data['location'] ?? '').toLowerCase();
        
        // Check for exact or partial matches
        bool hasMatch = messageWords.any((word) => 
          name.contains(word) || location.contains(word)
        );
        
        if (hasMatch) {
          matchingTours.add(doc);
        }
      }
      
      if (matchingTours.isEmpty) {
        return null; // Let AI handle it
      }
      
      String response = "Found ${matchingTours.length} Sri Lankan tour(s):\n\n";
      
      for (int i = 0; i < matchingTours.length && i < 4; i++) {
        var data = matchingTours[i].data() as Map<String, dynamic>;
        String tourName = data['name'] ?? data['title'] ?? 'Unnamed Event';
        String location = data['location'] ?? 'Location TBA';
        String price = _safeToString(data['price'], 'Contact for pricing');
        bool isEnded = data['isEnded'] ?? false;
        
        response += "${i + 1}. $tourName\n";
        response += "   📍 Location: $location\n";
        response += "   💰 Price: LKR $price\n";
        response += "   📊 Status: ${isEnded ? 'Ended' : 'Available'}\n\n";
      }
      
      response += "For detailed info, ask: 'Tell me more about [tour name]'\n";
      response += "Visit Home screen to book available tours!";
      
      return response;
      
    } catch (e) {
      print('Error searching tours: $e');
      return null;
    }
  }

  Future<String?> _getDestinationInfo(String message) async {
    try {
      List<String> destinations = ['sigiriya', 'ella', 'kandy', 'colombo', 'galle', 'nuwara eliya', 'anuradhapura', 'bentota', 'hikkaduwa'];
      String targetDestination = '';
      
      for (String dest in destinations) {
        if (message.contains(dest)) {
          targetDestination = dest;
          break;
        }
      }
      
      if (targetDestination.isNotEmpty) {
        QuerySnapshot snapshot = await _firestore.collection('events').get();
        
        List<QueryDocumentSnapshot> activeDestinationTours = [];
        
        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          String location = (data['location'] ?? '').toLowerCase();
          String name = (data['name'] ?? data['title'] ?? '').toLowerCase();
          bool isEnded = data['isEnded'] ?? false;
          
          if ((location.contains(targetDestination) || name.contains(targetDestination)) && !isEnded) {
            activeDestinationTours.add(doc);
          }
        }
        
        String response = "${targetDestination.toUpperCase()} Tours:\n\n";
        
        if (activeDestinationTours.isNotEmpty) {
          response += "🟢 Available Tours:\n";
          for (int i = 0; i < activeDestinationTours.length && i < 3; i++) {
            var data = activeDestinationTours[i].data() as Map<String, dynamic>;
            response += "• ${data['name'] ?? data['title'] ?? 'Tour'} - LKR ${_safeToString(data['price'], 'TBA')}\n";
          }
          response += "\n📲 Book these tours on the Home screen!";
          return response;
        }
        
        return null; // Let AI handle destination info
      }
      
      return "🗺️ Popular Sri Lankan Destinations:\n\n• Sigiriya - Ancient rock fortress\n• Ella - Hill country beauty\n• Kandy - Cultural capital\n• Colombo - Modern city\n• Galle - Historic fort\n\nAsk about tours to any destination!";
      
    } catch (e) {
      print('Error fetching destination info: $e');
      return null;
    }
  }

  Future<String> _getPriceInfo() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('events')
          .where('isEnded', isEqualTo: false)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return "No active tours with pricing available. Contact us:\n📧 support@travelon.com\n☎️ +94 11 123 4567";
      }

      List<int> prices = [];
      String response = "Current Sri Lankan Tour Pricing:\n\n";
      
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var priceField = data['price'] ?? data['cost'];
        if (priceField != null) {
          int price = int.tryParse(_safeToString(priceField, '0')) ?? 0;
          if (price > 0) {
            prices.add(price);
            response += "${data['name'] ?? data['title'] ?? 'Tour'}: LKR $price\n";
          }
        }
      }
      
      if (prices.isNotEmpty) {
        prices.sort();
        response += "\n📊 Price Range: LKR ${prices.first} - LKR ${prices.last}\n";
        response += "💡 Prices include transport and professional guide!\n";
        response += "\n📲 Visit Home screen for booking!";
      } else {
        response = "Contact us for pricing:\n📧 support@travelon.com\n☎️ +94 11 123 4567";
      }
      
      return response;
      
    } catch (e) {
      print('Error fetching price info: $e');
      return "I'm having trouble accessing pricing. Please visit the Home screen or contact support.";
    }
  }
}

class ChatMessage {
  final String message;
  final bool isUser;

  ChatMessage({required this.message, required this.isUser});
}