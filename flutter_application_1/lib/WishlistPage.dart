import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  // Function to delete an item from the wishlist
  Future<void> deleteFromWishlist(String docId) async {
    await FirebaseFirestore.instance.collection('wishlist').doc(docId).delete();
  }

  // Function to move an item from wishlist to cart
  Future<void> moveToCart(String docId, Map<String, dynamic> data) async {
    // Get the current user's UID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Add the userId to the data being moved to the cart
    data['userId'] = userId;

    // Add the selected item to the 'cart' collection in Firestore
    await FirebaseFirestore.instance.collection('cart').doc(docId).set(data);

    // Remove the item from the wishlist after moving to cart
    await deleteFromWishlist(docId);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference wishlistRef = FirebaseFirestore.instance.collection('wishlist');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
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
          stream: wishlistRef.snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if there are any items in the wishlist
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No items in your wishlist.'));
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                String docId = document.id; // Document ID for deletion and move to cart

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
                    subtitle: Text('Condition: ${data['condition']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteFromWishlist(docId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from Wishlist')),
                            );
                          },
                        ),
                        // Move to Cart Button
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                          onPressed: () {
                            moveToCart(docId, data);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Moved to Cart')),
                            );
                          },
                        ),
                      ],
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
