import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../services/cloud_repository.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile _profile = UserProfile();
  final CloudRepository _cloudRepository = CloudRepository();

  UserProfile get profile => _profile;
  bool get hasProfile => _profile.isComplete;

  UserProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        final profileData = json.decode(profileJson) as Map<String, dynamic>;
        _profile = UserProfile.fromJson(profileData);
        notifyListeners();
      }

      // If logged in, try to sync from cloud
      if (_cloudRepository.isLoggedIn) {
        final cloudProfile = await _cloudRepository.loadProfile();
        if (cloudProfile != null) {
          // Merge: prefer cloud data if available
          _profile = cloudProfile;
          await _saveToLocal();
          notifyListeners();
        }
      }
    } catch (e) {
      // Use default empty profile if loading fails
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    notifyListeners();

    try {
      // Save locally
      await _saveToLocal();

      // Save to cloud if logged in
      if (_cloudRepository.isLoggedIn) {
        await _cloudRepository.saveProfile(profile);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(_profile.toJson()));
    } catch (e) {
      // Handle error silently
    }
  }

  // Sync profile to cloud (called on sign-in)
  Future<void> syncToCloud() async {
    if (_cloudRepository.isLoggedIn && hasProfile) {
      await _cloudRepository.saveProfile(_profile);
    }
  }

  Future<void> updateProfile({
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    List<Disease>? diseases,
    HealthGoal? goal,
  }) async {
    _profile = _profile.copyWith(
      age: age,
      gender: gender,
      height: height,
      weight: weight,
      diseases: diseases,
      goal: goal,
    );
    await saveProfile(_profile);
  }
}
