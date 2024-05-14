import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String name;
  final String role;
  final String address;

  Profile({
    required this.id,
    required this.name,
    required this.role,
    required this.address,
  });
}

class ProfileManager extends ChangeNotifier {
  List<Profile> _profiles = [];

  List<Profile> get profiles => _profiles;

  void addProfile(Profile profile) {
    _profiles.add(profile);
    notifyListeners(); // Notify listeners to update UI
  }

  void updateProfile(String id, Profile updatedProfile) {
    int index = _profiles.indexWhere((profile) => profile.id == id);
    if (index != -1) {
      _profiles[index] = updatedProfile;
      notifyListeners(); // Notify listeners to update UI
    }
  }

  void deleteProfile(String id) {
    _profiles.removeWhere((profile) => profile.id == id);
    notifyListeners(); // Notify listeners to update UI
  }
}
