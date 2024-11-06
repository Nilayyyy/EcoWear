import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class RecyclePage extends StatefulWidget {
  const RecyclePage({super.key});

  @override
  State<RecyclePage> createState() => _RecyclePageState();
}

class _RecyclePageState extends State<RecyclePage> {
  final _formKey = GlobalKey<FormState>();
  String? clothType;
  String? clothSize;
  String? clothCondition;
  File? _image;

  final List<String> clothTypes = [
    'T-Shirt',
    'Jeans',
    'Shirt',
    'Jacket',
    'Other'
  ];
  final List<String> clothSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> clothConditions = ['Excellent', 'Good', 'Fair', 'Poor'];

  final picker = ImagePicker();

  // Function to pick image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Function to calculate price based on condition
  double calculatePrice(String condition) {
    double basePrice = 20.0;
    double price;

    switch (condition) {
      case 'Excellent':
        price = basePrice * 1.5;
        break;
      case 'Good':
        price = basePrice * 1.2;
        break;
      case 'Fair':
        price = basePrice;
        break;
      case 'Poor':
        price = basePrice * 0.8;
        break;
      default:
        price = basePrice;
    }

    return price;
  }

  // Function to submit data to Firestore
  Future<void> submitCloth() async {
    if (_formKey.currentState!.validate() && _image != null) {
      _formKey.currentState!.save();

      try {
        // Upload image to Firebase Storage
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference storageRef =
            FirebaseStorage.instance.ref().child('clothes').child(fileName);
        UploadTask uploadTask = storageRef.putFile(_image!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Calculate price based on condition
        double price = calculatePrice(clothCondition!);

        // Store cloth details in Cloud Firestore
        CollectionReference clothesRef =
            FirebaseFirestore.instance.collection('clothes');

        await clothesRef.add({
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'type': clothType,
          'size': clothSize,
          'condition': clothCondition,
          'price': price, // Add the calculated price field
          'imageURL': downloadURL,
          'status': 'resell', // 'resell' or 'recycle'
          'dateAdded': DateTime.now(), // Use Firestore's timestamp
          'daysSinceAdded': 0,
          'purchaseStatus': 'available', // 'available', 'sold'
          'purchasedBy': 'none', // Add this field with initial value 'none'
        });

        // Ensure widget is still mounted before using the context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cloth submitted successfully!')),
          );
        }

        // Clear form
        if (mounted) {
          _formKey.currentState!.reset();
          setState(() {
            _image = null;
          });
        }
      } catch (e) {
        // Ensure widget is still mounted before using the context
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    } else {
      // Ensure widget is still mounted before using the context
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please complete all fields and upload an image')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycle Clothes'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                // Cloth Type Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Cloth Type',
                    icon: Icon(Icons.category),
                  ),
                  value: clothType,
                  items: clothTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      clothType = val;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a cloth type' : null,
                ),

                // Cloth Size Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Cloth Size',
                    icon: Icon(Icons.fitness_center),
                  ),
                  value: clothSize,
                  items: clothSizes.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      clothSize = val;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a cloth size' : null,
                ),

                // Cloth Condition Dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Cloth Condition',
                    icon: Icon(Icons.assignment_turned_in),
                  ),
                  value: clothCondition,
                  items: clothConditions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      clothCondition = val;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select cloth condition' : null,
                ),

                const SizedBox(height: 20),

                // Image Upload Area
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200, // Adjust the height as needed
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.tealAccent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      shape: BoxShape.rectangle,
                    ),
                    child: _image == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add,
                                  size: 50,
                                  color: Colors.black38,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Tap to Upload Image',
                                  style: TextStyle(color: Colors.black38),
                                ),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Submit Button at the bottom
                ElevatedButton(
                  onPressed: submitCloth, // Correct function call
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Set the button color
                    foregroundColor: Colors.white, // Set the text color
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 70.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
