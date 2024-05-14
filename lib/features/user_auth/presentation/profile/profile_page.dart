import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofencefirebase/features/user_auth/presentation/profile/profile_data.dart';
import 'package:geofencefirebase/features/user_auth/presentation/profile/profiledisplay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ProfilePage extends StatefulWidget {
 @override
 _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
 final _formKey = GlobalKey<FormState>();
 final _nameController = TextEditingController();
 final _roleController = TextEditingController();
 final _addressController = TextEditingController();

 @override
 void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _addressController.dispose();
    super.dispose();
 }

 void _clearFormFields() {
  _nameController.clear();
  _roleController.clear();
  _addressController.clear();
}

 @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama'),
                validator: (value) {
                 if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                 }
                 return null;
                },
              ),
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                 if (value == null || value.isEmpty) {
                    return 'Please enter your role';
                 }
                 return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Alamat'),
                validator: (value) {
                 if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                 }
                 return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                 onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      String name = _nameController.text;
                      String role = _roleController.text;
                      String address = _addressController.text;

                      // Insert the data into the database
                      _insertProfile(context, name, role, address);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
                         // Clear form fields after submission
                      _clearFormFields();
                    }
                 },
                 child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
 }

Future<void> _insertProfile(BuildContext context, String name, String role, String address) async {
  // Initialize Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Create a new document with a generated ID
  DocumentReference docRef = await firestore.collection('profiles').add({
    'name': name,
    'role': role,
    'address': address,
  });

  // Fetch the newly added profile data
  DocumentSnapshot docSnapshot = await docRef.get();
  Map<String, dynamic> newProfileData = docSnapshot.data() as Map<String, dynamic>;

  // Ensure all values are strings
  Map<String, String> newProfileDataString = {
    'name': newProfileData['name'] as String,
    'role': newProfileData['role'] as String,
    'address': newProfileData['address'] as String,
  };

  // Navigate to the new page after data insertion
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ProfileDisplayPage(profile: newProfileDataString)),
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Data Saved Successfully')),
  );
  Navigator.pop(context); // Navigate back to ProfileDisplayPage after adding profile
}


}
