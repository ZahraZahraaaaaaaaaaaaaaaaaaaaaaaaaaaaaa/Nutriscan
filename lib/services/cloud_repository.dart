import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/product.dart';

class CloudRepository {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  CloudRepository() {
    try {
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;
    } catch (e) {
      // Firebase not configured
      _firestore = null;
      _auth = null;
    }
  }

  bool get isLoggedIn => _auth?.currentUser != null;
  String? get userId => _auth?.currentUser?.uid;

  // User Profile Methods
  Future<void> saveProfile(UserProfile profile) async {
    if (!isLoggedIn || userId == null || _firestore == null) return;

    try {
      await _firestore!.collection('users').doc(userId).set({
        'profile': profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<UserProfile?> loadProfile() async {
    if (!isLoggedIn || userId == null || _firestore == null) return null;

    try {
      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?['profile'] != null) {
        return UserProfile.fromJson(doc.data()!['profile']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Favorites Methods
  Future<void> saveFavorites(List<String> barcodes) async {
    if (!isLoggedIn || userId == null || _firestore == null) return;

    try {
      await _firestore!.collection('users').doc(userId).set({
        'favorites': barcodes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<String>?> loadFavorites() async {
    if (!isLoggedIn || userId == null || _firestore == null) return null;

    try {
      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?['favorites'] != null) {
        return List<String>.from(doc.data()!['favorites']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Recent Scans Methods
  Future<void> saveRecents(List<Product> products) async {
    if (!isLoggedIn || userId == null || _firestore == null) return;

    try {
      final recentsData = products.take(20).map((product) => {
        'barcode': product.barcode,
        'name': product.name,
        'brand': product.brand,
        'imageUrl': product.imageUrl,
        'scannedAt': FieldValue.serverTimestamp(),
      }).toList();

      await _firestore!.collection('users').doc(userId).set({
        'recents': recentsData,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<Map<String, dynamic>>?> loadRecents() async {
    if (!isLoggedIn || userId == null || _firestore == null) return null;

    try {
      final doc = await _firestore!.collection('users').doc(userId).get();
      if (doc.exists && doc.data()?['recents'] != null) {
        return List<Map<String, dynamic>>.from(doc.data()!['recents']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Clear all user data
  Future<void> clearUserData() async {
    if (!isLoggedIn || userId == null || _firestore == null) return;

    try {
      await _firestore!.collection('users').doc(userId).delete();
    } catch (e) {
      // Handle error silently
    }
  }
}
