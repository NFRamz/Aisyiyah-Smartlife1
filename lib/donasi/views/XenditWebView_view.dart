import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';

class XenditWebView_view extends StatefulWidget {
  final String url;
  const XenditWebView_view({Key? key, required this.url}) : super(key: key);

  @override
  State<XenditWebView_view> createState() => _XenditWebView_viewState();
}

class _XenditWebView_viewState extends State<XenditWebView_view> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Deteksi jika pembayaran sukses (redirect URL)
            // Sesuaikan dengan settingan redirect di Dashboard Xendit Anda
            if (url.contains('success')) {
              Get.back(); // Tutup WebView
              Get.snackbar("Berhasil", "Terima kasih atas pembayaran Anda!",
                  backgroundColor: Colors.green, colorText: Colors.white);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Selesaikan Pembayaran")
      ),
      body: WebViewWidget(controller: _controller),

    );
  }
}