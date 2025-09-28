import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data_model/traveller.dart';

class TravellerService {
  final _collection = FirebaseFirestore.instance.collection('users-travellers');

  Future<Traveller?> getTraveller(String uid) async {
    try {
      debugPrint('Attempting to read traveller with uid: $uid');
      final doc = await _collection.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        debugPrint('Read successful: ${doc.data()}');
        return Traveller.fromFirestore(doc.id, doc.data()!);
      } else {
        debugPrint('No traveller found for uid: $uid');
      }
    } catch (e) {
      debugPrint('Error reading traveller: $e');
    }
    return null;
  }

  Future<void> updateTraveller(Traveller traveller) async {
    try {
      debugPrint('Attempting to write traveller: ${traveller.toMap()}');
      await _collection
          .doc(traveller.id)
          .set(traveller.toMap(), SetOptions(merge: true));
      debugPrint('Write successful for traveller: ${traveller.id}');
    } catch (e) {
      debugPrint('Error writing traveller: $e');
    }
  }

  Future<List<Traveller>> getAllTravellers() async {
    final query = await _collection.get();
    return query.docs
        .map((doc) => Traveller.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<void> updateTravellerProfileImage(String uid, String imageUrl) async {
    await FirebaseFirestore.instance.collection('users-travellers').doc(uid).update({'profileImage': imageUrl});
  }
}
