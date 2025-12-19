import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jualbeli_buku_bekas/models/cart_item_model.dart';

class MidtransService {
  static const String _serverKey = 'SB-Mid-server-Hske1222PcT2W1R9QoSSjVPa';
  static const String _baseUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';

  Future<String> getPaymentUrl({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required List<CartItemModel> items,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_serverKey:'))}',
    };

    final List<Map<String, dynamic>> itemDetails = items.map((item) {
      return {
        "id": item.book.id,
        "price": item.book.price,
        "quantity": item.quantity,
        "name": item.book.title.length > 50 
            ? item.book.title.substring(0, 50) 
            : item.book.title,
      };
    }).toList();

    final body = jsonEncode({
      "transaction_details": {
        "order_id": orderId,
        "gross_amount": grossAmount,
      },
      "item_details": itemDetails, 
      "credit_card": {
        "secure": true
      },
      "customer_details": {
        "first_name": customerName,
        "email": customerEmail,
        "phone": customerPhone,
      }
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return json['redirect_url'];
      } else {
        throw Exception('Gagal connect Midtrans: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error Midtrans Service: $e');
    }
  }
}