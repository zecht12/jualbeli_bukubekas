import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HalamanCheckout extends StatefulWidget {
  final String bookId;
  final String bookTitle;
  final double bookPrice;

  const HalamanCheckout({
    super.key,
    required this.bookId,
    required this.bookTitle,
    required this.bookPrice,
  });

  @override
  State<HalamanCheckout> createState() => _HalamanCheckoutState();
}

class _HalamanCheckoutState extends State<HalamanCheckout> {
  int quantity = 1;
  String selectedOption = 'ambil ditempat';
  final TextEditingController _alamatController = TextEditingController();
  double shippingCost = 0;
  double totalCost = 0;

  void _calculateShipping() {
    String alamat = _alamatController.text.toLowerCase();
    if (alamat.contains('solo') && alamat.contains('jawa tengah')) {
      shippingCost = 8000;
    } else if (alamat.contains('jawa')) {
      shippingCost = 27000;
    } else {
      shippingCost = 100000;
    }
  }

  void _calculateTotal() {
    _calculateShipping();
    totalCost = (widget.bookPrice * quantity) + (selectedOption == 'paket' ? shippingCost : 0);
  }

  void _saveCheckout() async {
    await FirebaseFirestore.instance.collection('checkouts').add({
      'bookId': widget.bookId,
      'bookTitle': widget.bookTitle,
      'quantity': quantity,
      'shippingOption': selectedOption,
      'alamatPengiriman': selectedOption == 'paket' ? _alamatController.text : '',
      'shippingCost': selectedOption == 'paket' ? shippingCost : 0,
      'totalCost': totalCost,
      'timestamp': Timestamp.now(),
    });
  }

  void _showInvoiceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invoice'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Buku: ${widget.bookTitle}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              Text('Jumlah: $quantity', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text('Opsi Pengiriman: $selectedOption', style: const TextStyle(fontSize: 16)),
              if (selectedOption == 'paket') ...[
                const SizedBox(height: 10),
                Text('Alamat: ${_alamatController.text}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text('Biaya Pengiriman: Rp $shippingCost', style: const TextStyle(fontSize: 16)),
              ],
              const SizedBox(height: 10),
              Text('Total: Rp $totalCost', style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showScreenshotAlert() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Harap screenshot invoice untuk referensi Anda.'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _calculateTotal();
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buku: ${widget.bookTitle}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Harga: Rp ${widget.bookPrice}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value) ?? 1;
                  _calculateTotal();
                });
              },
            ),
            const SizedBox(height: 20),
            const Text('Opsi Pengiriman:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: selectedOption,
              onChanged: (newValue) {
                setState(() {
                  selectedOption = newValue!;
                  _calculateTotal();
                });
              },
              items: <String>['ambil ditempat', 'paket']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (selectedOption == 'paket') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat Pengiriman'),
                onChanged: (value) {
                  setState(() {
                    _calculateTotal();
                  });
                },
              ),
            ],
            const SizedBox(height: 20),
            Text('Total: Rp $totalCost', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveCheckout();
                _showInvoiceDialog();
                _showScreenshotAlert();
              },
              child: const Text('Checkout'),
            ),
          ],
        ),
      ),
    );
  }
}