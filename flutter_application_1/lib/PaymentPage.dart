import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Function onPlaceOrder;

  const PaymentPage({Key? key, required this.onPlaceOrder}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = "COD"; // Default selected payment method is COD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Payment Method: COD (Preselected)
            ListTile(
              title: const Text('Cash on Delivery (COD)'),
              leading: Radio<String>(
                value: 'COD',
                groupValue: selectedPaymentMethod,
                onChanged: (String? value) {
                  setState(() {
                    selectedPaymentMethod = value!;
                  });
                },
              ),
            ),
            const Divider(),
            // Disabled Payment Options
            ListTile(
              title: const Text('Credit/Debit Card (Disabled)'),
              leading: Radio<String>(
                value: 'Card',
                groupValue: selectedPaymentMethod,
                onChanged: null, // Disabled option
              ),
            ),
            ListTile(
              title: const Text('Net Banking (Disabled)'),
              leading: Radio<String>(
                value: 'NetBanking',
                groupValue: selectedPaymentMethod,
                onChanged: null, // Disabled option
              ),
            ),
            ListTile(
              title: const Text('UPI (Disabled)'),
              leading: Radio<String>(
                value: 'UPI',
                groupValue: selectedPaymentMethod,
                onChanged: null, // Disabled option
              ),
            ),
            const Spacer(),
            // Place Order Button
            ElevatedButton(
              onPressed: () {
                widget.onPlaceOrder();
                Navigator.pop(context); // Navigate back to CartPage after placing the order
              },
              child: const Text('Place My Order'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                minimumSize: const Size(double.infinity, 50), // Full-width button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
