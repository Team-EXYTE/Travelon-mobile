import 'package:cloud_firestore/cloud_firestore.dart';
import '../data_model/traveller.dart';

class TravellerService {
  final _collection = FirebaseFirestore.instance.collection('users-travellers');

  // Fetch ticket IDs for a user and event
  Future<List<String>> getTicketIdsForEvent(
    String userId,
    String eventId,
  ) async {
    final eventDoc =
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .get();
    final data = eventDoc.data();
    if (data == null) return [];
    final tickets = data['tickets'] as Map<String, dynamic>?;
    if (tickets == null) return [];
    final ids = tickets[userId];
    if (ids == null) return [];
    return List<String>.from(ids);
  }

  Future<Traveller?> getTraveller(String uid) async {
    try {
      print('Attempting to read traveller with uid: $uid');
      final doc = await _collection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        print('Read successful: ${doc.data()}');
        return Traveller.fromFirestore(doc.id, doc.data()!);
      } else {
        print('No traveller found for uid: $uid');
      }
    } catch (e) {
      print('Error reading traveller: $e');
    }
    return null;
  }

  Future<void> updateTraveller(Traveller traveller) async {
    try {
      print('Attempting to write traveller: ${traveller.toMap()}');
      await _collection
          .doc(traveller.id)
          .set(traveller.toMap(), SetOptions(merge: true));
      print('Write successful for traveller: ${traveller.id}');
    } catch (e) {
      print('Error writing traveller: $e');
    }
  }

  Future<List<Traveller>> getAllTravellers() async {
    final query = await _collection.get();
    return query.docs
        .map((doc) => Traveller.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateTravellerProfileImage(String uid, String imageUrl) async {
    await FirebaseFirestore.instance
        .collection('users-travellers')
        .doc(uid)
        .update({'profileImage': imageUrl});
  }
}
