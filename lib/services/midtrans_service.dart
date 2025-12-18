import 'dart:convert';
import 'package:http/http.dart' as http;

class MidtransService {
  static const String _serverKey = 'SB-Mid-server-Hske1222PcT2W1R9QoSSjVPa';
  
  static const String _baseUrl = 'https://app.sandbox.midtrans.com/snap/v1/transactions';
  Future<String> getPaymentUrl({
    required String orderId,
    required int grossAmount,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
  }) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_serverKey:'))}',
    };

    final body = jsonEncode({
      "transaction_details": {
        "order_id": orderId,
        "gross_amount": grossAmount,
      },
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