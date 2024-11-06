import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user

class FashionPage extends StatelessWidget {
  const FashionPage({super.key});

  // Function to add to wishlist
  Future<void> addToWishlist(String clothId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('wishlist').doc(clothId).set(data);
  }

  // Function to add to cart
  Future<void> addToCart(String clothId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection('cart').doc(clothId).set(data);
  }

  // Function to show cloth details in a dialog
  void showClothDetails(BuildContext context, String clothId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ),
                // Cloth image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    data['imageURL'],
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${data['type']} - Size ${data['size']}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Condition: ${data['condition']}', style: const TextStyle(fontSize: 18)),
                Text('Price: Rs${data['price']}', style: const TextStyle(fontSize: 18, color: Colors.teal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Wishlist and Add to Cart buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: Colors.red),
                      onPressed: () {
                        addToWishlist(clothId, data); // Use clothId here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Wishlist')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                      onPressed: () {
                        addToCart(clothId, data); // Use clothId here
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Cart')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get current user's UID to filter out their own clothes
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // Firestore reference to the 'clothes' collection
    CollectionReference clothesRef = FirebaseFirestore.instance.collection('clothes');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fashion Up'),
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
          stream: clothesRef
              .where('status', isEqualTo: 'resell')
              .where('purchaseStatus', isEqualTo: 'available')
              .where('userId', isNotEqualTo: userId) // Filter out the user's own clothes
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Check if there are any clothes available for resale
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No clothes available for resale.'));
            }

            // Build the grid of clothes
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 2 slides in a row
                childAspectRatio: 0.75, // Adjust height and width ratio
                crossAxisSpacing: 10.0, // Horizontal spacing
                mainAxisSpacing: 10.0, // Vertical spacing
              ),
              padding: const EdgeInsets.all(16.0), // Padding around the grid
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = snapshot.data!.docs[index];
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

                // Get the cloth ID (document ID)
                String clothId = document.id;

                return GestureDetector(
                  onTap: () {
                    showClothDetails(context, clothId, data); // Show details in dialog
                  },
                  child: Card(
                    elevation: 6, // Add shadow effect
                    child: Column(
                      children: [
                        // Image at the top
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            child: Image.network(
                              data['imageURL'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Details below the image
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${data['type']} - Size ${data['size']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Condition: ${data['condition']}'),
                              Text('Price: Rs${data['price']}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        // Wishlist and Add to Cart buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border, color: Colors.red),
                              onPressed: () {
                                addToWishlist(clothId, data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to Wishlist')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                              onPressed: () {
                                addToCart(clothId, data);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to Cart')),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
