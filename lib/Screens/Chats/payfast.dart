import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ustaad/Helpers/loader.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayFastWebView extends StatefulWidget {
  final String payfastUrl;
  final Map<String, String> formFields;

  const PayFastWebView({
    super.key,
    required this.payfastUrl,
    required this.formFields,
  });

  @override
  State<PayFastWebView> createState() => _PayFastWebViewState();
}

class _PayFastWebViewState extends State<PayFastWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasCompleted = false;

  @override
  void initState() {
    super.initState();

    // Create WebViewController
    final tempController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("Page started loading: $url");
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            print("Page finished loading: $url");
            setState(() => isLoading = false);
          },
          onNavigationRequest: _handleNavigation,
          onWebResourceError: _handleError,
        ),
      );

    // Build POST body
    final postData = widget.formFields.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    print("POST data: $postData");

    // Load POST request
    tempController.loadRequest(
      Uri.parse(widget.payfastUrl),
      method: LoadRequestMethod.post,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: Uint8List.fromList(postData.codeUnits),
    );

    controller = tempController;
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url.toLowerCase();
    print("Navigating to: $url");

    if (url.contains("/payfast/success")) {
      hasCompleted = true;
      print("Payment success detected!");
      Navigator.pop(context, "success");
      return NavigationDecision.prevent;
    }

    if (url.contains("/payfast/failure")) {
      hasCompleted = true;
      print("Payment failure detected!");
      Navigator.pop(context, "failure");
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _handleError(WebResourceError error) {
    print("WebView error: ${error.description}");
    if (!hasCompleted && mounted) {
      Navigator.pop(context, "error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!hasCompleted) {
          print("Payment cancelled by user!");
          Navigator.pop(context, "cancelled");
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("PayFast Payment")),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading) const Center(child: GifLoader()),
          ],
        ),
      ),
    );
  }
}
