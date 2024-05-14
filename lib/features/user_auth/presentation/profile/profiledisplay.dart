import 'package:flutter/material.dart';
import 'package:geofencefirebase/features/user_auth/presentation/profile/profile_page.dart';
import 'editprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDisplayPage extends StatefulWidget {
  final Map<String, String> profile;

  ProfileDisplayPage({required this.profile});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${widget.profile['name']}'),
                      Text('Role: ${widget.profile['role']}'),
                      Text('Address: ${widget.profile['address']}'),
                    ],
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
// Inside ProfileDisplayPage, when navigating to EditProfilePage
final editedData = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => EditProfilePage(profileData: {
   ...widget.profile,
    'id': widget.profile['id'], // Ensure the document ID is included
  })),
);

                        if (editedData!= null) {
                          // Update the profile data in Firestore
                          await _firestore.collection('profiles').doc(widget.profile['id']).update(editedData);
                          // Optionally, update the local profile data if you're maintaining a local list
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        // Delete the profile from Firestore
                        await _firestore.collection('profiles').doc(widget.profile['id']).delete();
                        // Optionally, remove the profile from a local list if you're maintaining one
                        // This step depends on how you're managing your data locally
                        Navigator.pop(context); // Navigate back after deletion
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20), // Add some space between the profile info and the add button
            ElevatedButton(
              onPressed: () {
                // Navigate to the AddProfilePage or handle the add profile logic here
                // This is a placeholder for your add profile logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
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
