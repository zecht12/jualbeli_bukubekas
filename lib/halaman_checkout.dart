import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String selectedPaymentMethod = 'COD';
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  double shippingCost = 0;
  double totalCost = 0;
  Map<String, dynamic>? bookDetails;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
    _fetchUserData();
    _alamatController.addListener(_updateShippingCost);
  }

  @override
  void dispose() {
    _alamatController.removeListener(_updateShippingCost);
    _alamatController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _fetchBookDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('books')
        .doc(widget.bookId)
        .get();

    setState(() {
      bookDetails = doc.data() as Map<String, dynamic>?;
      if (bookDetails != null && bookDetails!['jumlah_buku'] == 0) {
        bookDetails!['status'] = 'terjual';
      }
    });
  }

  void _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      if (userData != null) {
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _emailController.text = userData['email'] ?? '';
          if (userData['alamat'] != null && userData['alamat'].isNotEmpty) {
            _alamatController.text = userData['alamat'];
          }
        });
      }
    }
  }

  void _updateStock() async {
    if (bookDetails != null) {
      int currentStock = bookDetails!['jumlah_buku'];
      if (quantity > currentStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Jumlah yang diminta melebihi stok yang tersedia')),
        );
      } else {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .update({
          'jumlah_buku': currentStock - quantity,
          'status': currentStock - quantity == 0 ? 'terjual' : 'ready',
        });
        await FirebaseFirestore.instance.collection('checkouts').add({
          'bookId': widget.bookId,
          'bookTitle': widget.bookTitle,
          'bookPrice': widget.bookPrice,
          'quantity': quantity,
          'name': _nameController.text,
          'alamat': selectedOption == 'dikirim' ? _alamatController.text : null,
          'paymentMethod': selectedPaymentMethod,
          'email': _emailController.text,
          'totalCost': totalCost,
          'status': 'pending',
        });

        _showInvoice();
      }
    }
  }

  void _updateShippingCost() {
    String alamat = _alamatController.text.toLowerCase();
    if (alamat.contains('solo') || alamat.contains('surakarta')) {
      shippingCost = 8000;
    } else if (alamat.contains('jawa tengah')) {
      shippingCost = 27000;
    } else {
      shippingCost = 50000;
    }
    setState(() {
      totalCost = widget.bookPrice * quantity + (selectedOption == 'dikirim' ? shippingCost : 0);
    });
  }

  void _showInvoice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Invoice')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama: ${_nameController.text}'),
            Text('Judul Buku: ${widget.bookTitle}'),
            Text('Jumlah: $quantity'),
            Text('Total Harga: Rp ${totalCost.toStringAsFixed(2)}'),
            if (selectedPaymentMethod == 'Bank BNI')
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Silakan transfer ke nomor rekening:'),
                  Text('5264 2222 7329 9099 (Bank BNI)'),
                ],
              ),
            const SizedBox(height: 16),
            const Text(
              'Harap screenshot invoice ini sebagai bukti transaksi.',
              style: TextStyle(color: Colors.red),
            ),
            const Text(
              'Harap kirim bukti transaksi ke email brikut:',
            ),
            const Text(
              'gilangprimaertansyah76@gmail.com',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    totalCost = widget.bookPrice * quantity + (selectedOption == 'dikirim' ? shippingCost : 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: bookDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(bookDetails!['cover']),
                    const SizedBox(height: 16),
                    Text(
                      widget.bookTitle,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Harga: Rp ${widget.bookPrice.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),
                    Text('Stok: ${bookDetails!['jumlah_buku']}'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Nama Lengkap'),
                    ),
                    const SizedBox(height: 16),
                    if (selectedOption == 'dikirim')
                      TextField(
                        controller: _alamatController,
                        decoration: const InputDecoration(labelText: 'Alamat'),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          quantity = int.tryParse(value) ?? 1;
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Jumlah Buku'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButton<String>(
                      value: selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedOption = newValue!;
                          selectedPaymentMethod = 'COD';
                        });
                      },
                      items: <String>['ambil ditempat', 'dikirim']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (selectedOption == 'dikirim')
                      DropdownButton<String>(
                        value: selectedPaymentMethod,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedPaymentMethod = newValue!;
                          });
                        },
                        items: <String>['COD', 'Bank BNI']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    if (selectedOption == 'dikirim' && selectedPaymentMethod == 'Bank BNI')
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                          'Silakan transfer ke nomor rekening:\n5264 2222 7329 9099 (Bank BNI)',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: bookDetails!['status'] == 'terjual' ? null : _updateStock,
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
