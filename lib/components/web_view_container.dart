import 'package:flutter/material.dart';
import 'package:gbooks/models/book.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  const WebViewContainer({super.key, required this.book});

  final Book book;

  @override
  State<WebViewContainer> createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  late String url;

  late WebViewController controller;

  @override
  void initState() {
    super.initState();
    url = widget.book.accessInfo.webReaderLink;
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(url);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book.volumeInfo.title),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
