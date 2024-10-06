import 'package:flutter/material.dart';
import 'package:rc168/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FBMessengerPage extends StatefulWidget {
  final String htmlUrl;
  FBMessengerPage({Key? key, required this.htmlUrl}) : super(key: key);

  @override
  _FBMessengerPageState createState() => _FBMessengerPageState();
}

class _FBMessengerPageState extends State<FBMessengerPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LINE Messenger'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF4F4E4C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          ),
        ),
      ),
      body: WebView(
        initialUrl: widget.htmlUrl,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (String url) async {
          // 获取页面HTML
          // final String htmlContent = await _controller.evaluateJavascript(
          //     "document.documentElement.outerHTML.toString()");
          // print(url);
          // // 根据HTML内容进行逻辑处理，例如触发本地通知
          // // 此处添加判断逻辑，根据实际情况触发通知
          // if (url.contains("success")) {
          //   final Uri uri = Uri.parse(url);
          //   final String orderId = uri.queryParameters['orderId'] ?? '';
          //   await showOrderPlacedNotification(orderId);
          // }
          // if (url.contains("fail")) {
          //   await showOrderCancelledNotification();
          // }
        },
      ),
    );
  }
}
