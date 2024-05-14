import 'package:flutter/material.dart';
import 'profiledisplay.dart';

class ProfileData {
 static List<Map<String, dynamic>> profiles = [];

 static void addProfile(Map<String, dynamic> profile) {
    profiles.add(profile);
 }

 static List<Map<String, dynamic>> getProfiles() {
    return profiles;
 }

 static void updateProfile(int index, Map<String, dynamic> updatedProfile) {
    profiles[index] = updatedProfile;
 }

 static void deleteProfile(int index) {
    profiles.removeAt(index);
 }
}