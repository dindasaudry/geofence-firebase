import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, String?> profileData;

  EditProfilePage({required this.profileData});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _addressController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData['name']);
    _roleController = TextEditingController(text: widget.profileData['role']);
    _addressController = TextEditingController(text: widget.profileData['address']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: _roleController, decoration: InputDecoration(labelText: 'Role')),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'Address')),
            ElevatedButton(
              onPressed: () async {
                // Check if the document exists
                final docSnapshot = await _firestore.collection('profiles').doc(widget.profileData['id']).get();
                if (!docSnapshot.exists) {
                  // Handle the case where the document does not exist
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile not found')));
                  return; // Exit the function early
                }

                // If the document exists, proceed to update
                await _firestore.collection('profiles').doc(widget.profileData['id']).update({
                  'name': _nameController.text,
                  'role': _roleController.text,
                  'address': _addressController.text,
                });

                // Close the edit profile page and pass the updated profile data back
                Navigator.pop(context, {
                  'name': _nameController.text,
                  'role': _roleController.text,
                  'address': _addressController.text,
                });
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
