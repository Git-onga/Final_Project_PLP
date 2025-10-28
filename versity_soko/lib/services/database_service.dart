import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart';

class DatabaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('events');

  /// Save or update user profile info (name + image)
  Future<void> saveUserProfile({
    required String name,
    File? imageFile,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("No logged-in user found.");
    }

    final userRef = _database.ref('users/${user.uid}');
    final snapshot = await userRef.get();

    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      final ref = _storage.ref().child('user_images').child('${user.uid}.jpg');
      await ref.putFile(imageFile);
      imageUrl = await ref.getDownloadURL();
    }

    // If user entry doesn’t exist — create it
    if (!snapshot.exists) {
      await userRef.set({
        'id': user.uid,
        'name': name,
        'email': user.email,
        'profile_picture': imageUrl ?? '',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } else {
      // Update existing user data
      await userRef.update({
        'name': name,
        if (imageUrl != null) 'profile_picture': imageUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Retrieve current user's profile info
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final userRef = _database.ref('users/${user.uid}');
    final snapshot = await userRef.get();

    if (!snapshot.exists) return null;

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await _dbRef.get();

    print("Database path: ${_dbRef.path}");

    if (snapshot.exists && snapshot.value != null) {
      final Map data = snapshot.value as Map;
      return data.entries.map((entry) {
        return EventModel.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    } else {
      print("⚠️ No events found in Firebase!");
      return [];
    }
  }
}
