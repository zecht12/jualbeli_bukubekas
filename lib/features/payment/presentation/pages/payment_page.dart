import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jualbeli_buku_bekas/features/payment/logic/payment_controller.dart';

class PaymentPage extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onFinish;

  const PaymentPage({
    super.key,
    required this.paymentUrl,
    required this.onFinish,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final WebViewController _webViewController;
  final PaymentController _controller = PaymentController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onUrlChange: (UrlChange change) {
            final url = change.url ?? '';
            if (_controller.isPaymentSuccess(url)) {
              widget.onFinish();
              if (mounted && Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }
            else if (_controller.isPaymentPendingOrFailed(url)) {
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Silakan cek riwayat untuk status pembayaran')),
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}