import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  // Function to cancel the order and make the item available again
  Future<void> cancelOrder(String clothId, String orderId) async {
    // Update the purchaseStatus to 'available' and clear 'purchasedBy' in 'clothes' collection
    await FirebaseFirestore.instance.collection('clothes').doc(clothId).update({
      'purchaseStatus': 'available', // Mark item as available
      'purchasedBy': null, // Remove the user who purchased it
    });

    // Update the 'orderStatus' to 'cancelled' in 'orders' collection
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': 'cancelled',
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Reference to the 'orders' collection, filtering by the current user's UID
    Query ordersQuery = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId); // Filter by userId in 'orders'

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
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
          stream: ordersQuery.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if there are any orders for the user
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No orders placed.'));
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                String clothId = data['clothId']; // Get clothId from the order data
                String orderId = document.id; // Get the order document ID

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
                      'Condition: ${data['condition']}\nPrice: Rs${data['price']}\nStatus: ${data['orderStatus']}',
                    ),
                    trailing: data['orderStatus'] != 'cancelled'
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'cancel') {
                                // Show confirmation dialog before canceling the order
                                showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Cancel Order'),
                                      content: const Text(
                                          'Are you sure you want to cancel this order?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(); // Close dialog
                                          },
                                          child: const Text('No'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await cancelOrder(clothId, orderId); // Cancel order
                                            Navigator.of(context).pop(); // Close dialog
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Order canceled successfully!')),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red, // Red cancel button
                                          ),
                                          child: const Text(
                                            'Yes, Cancel',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'cancel',
                                child: Text(
                                  'Cancel Order',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          )
                        : null, // If order is cancelled, don't show the popup menu
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
