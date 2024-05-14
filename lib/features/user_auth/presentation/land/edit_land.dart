import 'package:flutter/material.dart';
import 'land_record.dart';
import 'package:geofencefirebase/features/user_auth/presentation/land/land_record.dart';

class EditLandPage extends StatefulWidget {
  final String documentId;
  final Function(Map<String, dynamic>) onUpdate;

  EditLandPage({required this.documentId, required this.onUpdate});

  @override
  _EditLandPageState createState() => _EditLandPageState();
}

class _EditLandPageState extends State<EditLandPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _landNameController;
  late TextEditingController _addressController;
  late TextEditingController _areaSizeController;
  late TextEditingController _ownershipCertificateController;
  late TextEditingController _ispoCertificateController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty strings if no initial values are available
    _landNameController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
    _areaSizeController = TextEditingController(text: '');
    _ownershipCertificateController = TextEditingController(text: '');
    _ispoCertificateController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _landNameController.dispose();
    _addressController.dispose();
    _areaSizeController.dispose();
    _ownershipCertificateController.dispose();
    _ispoCertificateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Land Record'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _landNameController,
              decoration: InputDecoration(labelText: 'Nama Lahan'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Alamat Lahan'),
            ),
            TextFormField(
              controller: _areaSizeController,
              decoration: InputDecoration(labelText: 'Luas Area Lahan'),
            ),
            TextFormField(
              controller: _ownershipCertificateController,
              decoration: InputDecoration(labelText: 'Nomor Sertifikat Hak Milik'),
            ),
            TextFormField(
              controller: _ispoCertificateController,
              decoration: InputDecoration(labelText: 'Nomor Sertifikat ISPO'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await widget.onUpdate(LandRecord(
                    landName: _landNameController.text,
                    address: _addressController.text,
                    areaSize: _areaSizeController.text,
                    ownershipCertificate: _ownershipCertificateController.text,
                    ispoCertificate: _ispoCertificateController.text,
                  ) as Map<String, dynamic>).then((value) {
                    // Optionally, fetch the updated list of records from Firestore
                    // and update your local state if needed
                    print("Data updated successfully");
                  }).catchError((error) {
                    print("Failed to update data: $error");
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
