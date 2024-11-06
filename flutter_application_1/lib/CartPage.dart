import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  // Function to remove an item from the cart
  Future<void> removeFromCart(String cartItemId) async {
    await FirebaseFirestore.instance
        .collection('cart')
        .doc(cartItemId)
        .delete();
  }

  // Function to purchase an item from the cart and move it to "orders" collection
  Future<void> purchaseItem(
      String cartItemId, Map<String, dynamic> data, String userId) async {
    // Update the purchase status and add the user's ID to purchasedBy in the 'clothes' collection
    await FirebaseFirestore.instance
        .collection('clothes')
        .doc(cartItemId)
        .update({
      'purchaseStatus': 'sold',
      'purchasedBy': userId, // Add user ID to purchasedBy field
    });

    // Add the purchased item to the 'orders' collection
    await FirebaseFirestore.instance.collection('orders').add({
      'clothId': cartItemId,
      'userId': userId,
      'type': data['type'],
      'size': data['size'],
      'condition': data['condition'],
      'price': data['price'],
      'imageURL': data['imageURL'],
      'orderStatus': 'Processing', // Initial order status
      'orderDate': DateTime.now(), // Add the order date
    });
  }

  // Function to purchase all items in the cart
  Future<void> purchaseAllItems(List<DocumentSnapshot> cartItems) async {
    String? userId =
        FirebaseAuth.instance.currentUser?.uid; // Get the current user's UID

    if (userId != null) {
      for (DocumentSnapshot cartItem in cartItems) {
        Map<String, dynamic> data = cartItem.data() as Map<String, dynamic>;
        String cartItemId =
            cartItem.id; // Use the document ID (cart item ID) directly

        // Purchase the item and remove it from the cart
        await purchaseItem(cartItemId, data, userId);
        await removeFromCart(cartItemId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference cartRef = FirebaseFirestore.instance.collection('cart');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
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
          stream: cartRef.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if there are any items in the cart
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No items in your cart.'));
            }

            // Display cart items
            List<DocumentSnapshot> cartItems = snapshot.data!.docs;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: cartItems.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      // Ensure the price is not null or missing
                      String price = data['price'] != null
                          ? data['price'].toString()
                          : 'N/A';

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: ListTile(
                          leading: Image.network(
                            data['imageURL'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text('${data['type']} - Size ${data['size']}'),
                          subtitle: Text(
                            'Condition: ${data['condition']}\nPrice: Rs $price',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              removeFromCart(
                                  document.id); // Use the document ID directly
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Removed from Cart')),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // Global Buy Now Button at the bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      await purchaseAllItems(
                          cartItems); // Purchase all items in the cart
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Order placed!')),
                      );
                    },
                    child: const Text('Buy Now'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      minimumSize:
                          const Size(double.infinity, 50), // Full-width button
                      backgroundColor: Colors.teal, // Set the button color
                      foregroundColor: Colors.white, // Set the text color
                      textStyle: const TextStyle(
                        fontSize: 18, // Font size for the button text
                        fontWeight: FontWeight.bold, // Bold text
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
