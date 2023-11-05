import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewDownload extends StatefulWidget {
  const WebViewDownload({super.key, required this.url});

  final String url;

  @override
  State<WebViewDownload> createState() => _WebViewDownloadState();
}

class _WebViewDownloadState extends State<WebViewDownload> {
  late String url;

  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    url = widget.url;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(url);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
