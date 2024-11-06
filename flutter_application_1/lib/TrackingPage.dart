import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final CollectionReference _clothesRef =
      FirebaseFirestore.instance.collection('clothes');
  Stream<QuerySnapshot>? _clothesStream;

  @override
  void initState() {
    super.initState();

    // Initialize the stream to listen for changes in the clothes collection
    _clothesStream = _clothesRef
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();

    // Implement a periodic timer to update 'daysSinceAdded'
    Timer.periodic(const Duration(hours: 24), (timer) async {
      QuerySnapshot snapshot =
          await _clothesRef.where('status', isEqualTo: 'resell').get();

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp dateAddedTimestamp = data['dateAdded'];
        DateTime dateAdded = dateAddedTimestamp.toDate();
        int days = DateTime.now().difference(dateAdded).inDays;

        if (days > 30 && data['status'] == 'resell') {
          // Update status to 'recycle'
          await doc.reference.update({'status': 'recycle'});
        } else {
          // Update daysSinceAdded
          await doc.reference.update({'daysSinceAdded': days});
        }
      }
    });
  }

  // Function to remove an item from the recycle list (either delete or change status)
  Future<void> removeFromRecycle(String clothId) async {
    await _clothesRef.doc(clothId).delete(); // Delete the document entirely
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track My Clothes'),
        backgroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _clothesStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check for existing data
            if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No clothes found.'));
            }

            // Build the list of clothes
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                Timestamp dateAddedTimestamp = data['dateAdded'];
                DateTime dateAdded = dateAddedTimestamp.toDate();
                int daysSinceAdded = DateTime.now().difference(dateAdded).inDays;
                String status = data['status'];
                String clothId = document.id;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: Image.network(
                      data['imageURL'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text('${data['type']} - Size ${data['size']}'),
                    subtitle: Text(
                      'Condition: ${data['condition']}\nDays Since Added: $daysSinceAdded\nStatus: $status',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Remove from Recycle'),
                              content: const Text(
                                  'Are you sure you want to remove this item from recycle?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    removeFromRecycle(clothId); // Call the remove function
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Remove'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
