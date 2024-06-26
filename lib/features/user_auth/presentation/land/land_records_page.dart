import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geofencefirebase/features/user_auth/presentation/land/edit_land.dart';
import 'package:geofencefirebase/features/user_auth/presentation/land/land_record.dart';

class LandRecordsPage extends StatelessWidget {
  final List<LandRecord> landRecords;

  LandRecordsPage({required this.landRecords});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Land Records'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('landRecords').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return ListView(
  children: snapshot.data!.docs.map((DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    // Provide default values for fields that might be null
    String profileName = data['profileName']?? 'Unknown';
    String landName = data['landName']?? 'Unknown';
    String address = data['address']?? 'Unknown';
    String areaSize = data['areaSize']?? 'Unknown';
    String ownershipCertificate = data['ownershipCertificate']?? 'Unknown';
    String ispoCertificate = data['ispoCertificate']?? 'Unknown';

    return ListTile(
      title: Text(profileName),
      subtitle: Text('Nama Lahan: $landName\nAlamat Lahan: $address\nLuas Area Lahan: $areaSize\nNomor Sertifikat Hak Milik: $ownershipCertificate\nNomor Sertifikat ISPO: $ispoCertificate'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              // Navigate to EditLandPage and pass the document ID
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditLandPage(
                    documentId: document.id,
                    onUpdate: (updatedData) {
                      // Update the document in Firestore
                      FirebaseFirestore.instance.collection('landRecords').doc(document.id).update(updatedData);
                    },
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              // Delete the document from Firestore
              FirebaseFirestore.instance.collection('landRecords').doc(document.id).delete();
            },
          ),
        ],
      ),
    );
  }).toList(),
);

        },
      ),
    );
  }
}
