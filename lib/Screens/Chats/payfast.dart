import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutterustad/Helpers/loader.dart';
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

  // Result captured the moment we SEE the success/failure URL, but we do NOT
  // pop until the WebView has actually loaded it so the backend redirect chain
  // (/payfast/ipn -> webhook, /payfast/success) runs server-side.
  String? _pendingResult;

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
            // Server has now responded to the success/failure request, so the
            // webhook/IPN has fired. Safe to close the WebView.
            if (_pendingResult != null && !hasCompleted) {
              hasCompleted = true;
              print("Closing WebView with result: $_pendingResult");
              Navigator.pop(context, _pendingResult);
            }
          },
          onNavigationRequest: _handleNavigation,
          onWebResourceError: _handleError,
        ),
      );

    // Build POST body
    final postData = widget.formFields.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
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

    // Capture the outcome but ALLOW the navigation so the WebView actually
    // requests the URL. Blocking it (prevent) skips the server callback, so the
    // backend never receives success/IPN and the webhook never fires. We pop in
    // onPageFinished once the server has processed the request.
    if (url.contains("/payfast/success")) {
      print("Payment success detected!");
      _pendingResult = "success";
    } else if (url.contains("/payfast/failure")) {
      print("Payment failure detected!");
      _pendingResult = "failure";
    }

    return NavigationDecision.navigate;
  }

  void _handleError(WebResourceError error) {
    print(
      "WebView error: ${error.description} (mainFrame: ${error.isForMainFrame})",
    );
    // Ignore sub-resource errors (favicon, images, etc.) and errors that arrive
    // after we've already captured a success/failure result.
    if (error.isForMainFrame == false) return;
    if (_pendingResult != null) return;
    if (!hasCompleted && mounted) {
      hasCompleted = true;
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
