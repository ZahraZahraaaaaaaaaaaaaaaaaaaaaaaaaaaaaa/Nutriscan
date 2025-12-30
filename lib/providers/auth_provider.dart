import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  User? _user;
  bool _isGuest = false;
  bool _firebaseAvailable = false;

  AuthProvider() {
    _initAuth();
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null || _isGuest;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  String? get displayName => _user?.displayName;
  String? get email => _user?.email;
  String? get photoURL => _user?.photoURL;
  String? get uid => _user?.uid;

  Future<void> _initAuth() async {
    try {
      // Try to initialize Firebase
      _auth = FirebaseAuth.instance;
      _googleSignIn = GoogleSignIn();
      _firebaseAvailable = true;

      // Check if user is already signed in
      _user = _auth?.currentUser;

      // Check if user is in guest mode
      final prefs = await SharedPreferences.getInstance();
      _isGuest = prefs.getBool('is_guest') ?? false;

      // If no guest mode set and no user, default to guest
      if (!_isGuest && _user == null) {
        _isGuest = true;
        await prefs.setBool('is_guest', true);
      }

      // Listen to auth state changes
      _auth?.authStateChanges().listen((User? user) {
        _user = user;
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Firebase not configured, using guest mode: $e');
      // Continue as guest if Firebase is not available
      _firebaseAvailable = false;
      _isGuest = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', true);
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    if (!_firebaseAvailable || _auth == null || _googleSignIn == null) {
      debugPrint('Firebase not available for Google Sign In');
      return false;
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return false; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth!.signInWithCredential(credential);
      _user = userCredential.user;
      _isGuest = false;

      // Save auth state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', false);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return false;
    }
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_guest', true);
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      if (_firebaseAvailable) {
        await _auth?.signOut();
        await _googleSignIn?.signOut();
      }
      _user = null;
      _isGuest = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_guest', false);

      notifyListeners();
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (_firebaseAvailable && _user != null) {
        await _user!.delete();
        await _googleSignIn?.signOut();
        _user = null;
      }

      _isGuest = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      notifyListeners();
    } catch (e) {
      debugPrint('Delete account error: $e');
      rethrow;
    }
  }
}
