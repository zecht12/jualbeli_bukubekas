// ignore_for_file: unused_import
import 'package:flutter/material.dart';

class PaymentController {
  bool isPaymentSuccess(String url) {
    
    final uri = Uri.parse(url);
    final status = uri.queryParameters['transaction_status'];
    final statusCode = uri.queryParameters['status_code'];

    if (statusCode == '200' && (status == 'settlement' || status == 'capture')) {
      return true;
    }
    
    return false;
  }

  bool isPaymentPendingOrFailed(String url) {
    final uri = Uri.parse(url);
    final status = uri.queryParameters['transaction_status'];
    
    return status == 'pending' || status == 'deny' || status == 'cancel';
  }
}