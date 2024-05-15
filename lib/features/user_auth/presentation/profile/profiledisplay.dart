import 'package:flutter/material.dart';
import 'package:geofencefirebase/features/user_auth/presentation/profile/add_profile.dart';
import 'package:geofencefirebase/features/user_auth/presentation/profile/profile_page.dart';
import 'editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDisplayPage extends StatefulWidget {
  final List<Map<String, String>> profiles;

  ProfileDisplayPage({required this.profiles});

  @override
  _ProfileDisplayPageState createState() => _ProfileDisplayPageState();
}

class _ProfileDisplayPageState extends State<ProfileDisplayPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.profiles.length,
                itemBuilder: (context, index) {
                  final profile = widget.profiles[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${profile['name']}'),
                      Text('Role: ${profile['role']}'),
                      Text('Address: ${profile['address']}'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () async {
                              // Navigate to EditProfilePage for the current profile
                              final editedData = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfilePage(profileData: {
                                 ...profile,
                                  'id': profile['id'], // Ensure the document ID is included
                                })),
                              );

                              if (editedData!= null) {
                                // Update the profile data in Firestore
                                await _firestore.collection('profiles').doc(profile['id']).update(editedData);
                                // Optionally, update the local profile data if you're maintaining a local list
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              // Delete the profile from Firestore
                              await _firestore.collection('profiles').doc(profile['id']).delete();
                              // Optionally, remove the profile from a local list if you're maintaining one
                              Navigator.pop(context); // Navigate back after deletion
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20), // Add some space between the profile info and the add button
            ElevatedButton(
              onPressed: () {
                // Navigate to the AddProfilePage or handle the add profile logic here
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProfilePage()),
                );
              },
              child: Text('Add Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
