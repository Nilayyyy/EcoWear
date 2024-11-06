import 'package:flutter/material.dart';
import 'RecyclePage.dart';
import 'TrackingPage.dart';
import 'FashionPage.dart';
import 'WishlistPage.dart'; // Import WishlistPage
import 'CartPage.dart'; // Import CartPage
import 'OrdersPage.dart'; // Import OrdersPage
import 'ProfilePage.dart'; // Import ProfilePage for editing user profile
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String username = "User";

  @override
  void initState() {
    super.initState();
    fetchUsername(); // Fetch the user's name when the page initializes
  }

  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Try to fetch the username from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // Check if the document exists and contains the 'name' field
      if (userDoc.exists && userDoc.data() != null) {
        var userData = userDoc.data() as Map<String, dynamic>;
        if (userData.containsKey('name')) {
          setState(() {
            username = userData['name']; // Update username with the 'name' field from Firestore
          });
        } else {
          // Fallback to email if 'name' field is not found
          setState(() {
            username = user.email ?? "User";
          });
        }
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to SignInPage is handled by AuthGate
  }

  // Function to show Help dialog with support email
  Future<void> showHelpDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text(
              'For support, please contact us at:\n\nsupport@safai.com\n\nWe\'re here to help you with any issues or questions you may have.'),
          actions: <Widget>[
            TextButton(
              child: const Text('See Tutorial'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                showTutorialDialog(context); // Show the tutorial dialog
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // Function to show tutorial dialog
  Future<void> showTutorialDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            width: 300,
            height: 400,
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    children: [
                      // Slide 1
                      Column(
                        children: [
                          Expanded(
                            child: Image.asset('assets/tutorial1.jpg', fit: BoxFit.contain),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('This is where you can put up your clothes for reselling and recycling.', textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      // Slide 2
                      Column(
                        children: [
                          Expanded(
                            child: Image.asset('assets/tutorial2.jpg', fit: BoxFit.contain),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Check your recycle progress here.', textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                      // Slide 3
                      Column(
                        children: [
                          Expanded(
                            child: Image.asset('assets/tutorial3.jpg', fit: BoxFit.contain),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Add items to your wishlist for later!', textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Close button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(color: Colors.red)),
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
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Hey $username!!"), // Display the username here
              accountEmail: null, // No need for email, we only show the name
              currentAccountPicture: const CircleAvatar(
                backgroundImage: AssetImage('assets/App_icon.jpg'),
                radius: 30.0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // My Profile Option
            ListTile(
              leading: const Icon(Icons.person, color: Colors.teal),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            // Wishlist option
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.teal),
              title: const Text('Wishlist'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistPage()),
                );
              },
            ),
            // Cart option
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.teal),
              title: const Text('Cart'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
            // My Orders option
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.teal),
              title: const Text('My Orders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
            ),
            const Divider(),
            // Help option
            ListTile(
              leading: const Icon(Icons.help, color: Colors.teal),
              title: const Text('Help'),
              onTap: () {
                showHelpDialog(context); // Show the Help dialog
              },
            ),
            const Divider(),
            // Sign Out option
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.teal),
              title: const Text('Sign Out'),
              onTap: () => signOut(context),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "S.A.F.A.I",
            style: TextStyle(
              fontSize: 30,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.tealAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          // Changed to Column to make sure it takes full height
          children: <Widget>[
            Expanded(
              // Ensures the content takes the full available height
              child: ListView(
                padding: const EdgeInsets.all(16.0), // Adjusted padding
                children: <Widget>[
                  SlideButton(
                    imagePath: 'assets/recycle_clothes.png',
                    label: 'Recycle Clothes',
                    icon: Icons.recycling,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecyclePage()),
                      );
                    },
                  ),
                  SlideButton(
                    imagePath: 'assets/track_donations.jpg',
                    label: 'Track My Recycles',
                    icon: Icons.track_changes,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TrackingPage()),
                      );
                    },
                  ),
                  SlideButton(
                    imagePath: 'assets/fashion_up.jpg',
                    label: 'Fashion Up',
                    icon: Icons.shopping_cart,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FashionPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideButton extends StatefulWidget {
  final String imagePath;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const SlideButton({
    super.key,
    required this.imagePath,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  _SlideButtonState createState() => _SlideButtonState();
}

class _SlideButtonState extends State<SlideButton> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // Trigger the function when tapped
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10), // Maintain the vertical margin
        height: 220, // Fixed height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
