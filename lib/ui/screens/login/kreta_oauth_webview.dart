// BASED OFF https://github.com/refilc/naplo/blob/master/refilc_mobile_ui/lib/screens/login/kreten_login.dart #4474562538219cdc2536f1c92ffc3ddd168185ab
// UNDER BSD-3 LICENSE
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webview_flutter/webview_flutter.dart';

class KretaOuathWebView extends StatefulWidget {
  const KretaOuathWebView(this.onDoneCallback, {Key key}) : super(key: key);

  final void Function(String) onDoneCallback;

  @override
  State<KretaOuathWebView> createState() => _KretaOuathWebViewState();
}

class _KretaOuathWebViewState extends State<KretaOuathWebView>
    with TickerProviderStateMixin {
  WebViewController controller;
  var loadingPercentage = 0;
  var currentUrl = '';

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (n) async {
          if (n.url.startsWith('https://mobil.e-kreta.hu')) {
            setState(() {
              loadingPercentage = 0;
              currentUrl = n.url;
            });

            List<String> requiredThings = n.url
                .replaceAll(
                    'https://mobil.e-kreta.hu/ellenorzo-student/prod/oauthredirect?code=',
                    '')
                .replaceAll(
                    '&scope=openid%20email%20offline_access%20kreta-ellenorzo-webapi.public%20kreta-eugyintezes-webapi.public%20kreta-fileservice-webapi.public%20kreta-mobile-global-webapi.public%20kreta-dkt-webapi.public%20kreta-ier-webapi.public&state=novynaplo&session_state=',
                    ':')
                .split(':');

            String code = requiredThings[0];

            widget.onDoneCallback(code);

            return NavigationDecision.prevent;
          } else {
            return NavigationDecision.navigate;
          }
        },
        onProgress: (progress) {
          setState(() {
            loadingPercentage = progress;
          });
        },
        onPageFinished: (url) {
          setState(() {
            loadingPercentage = 100;
          });
        },
      ))
      ..loadRequest(
        Uri.parse(
            'https://idp.e-kreta.hu/connect/authorize?prompt=login&nonce=wylCrqT4oN6PPgQn2yQB0euKei9nJeZ6_ffJ-VpSKZU&response_type=code&code_challenge_method=S256&scope=openid%20email%20offline_access%20kreta-ellenorzo-webapi.public%20kreta-eugyintezes-webapi.public%20kreta-fileservice-webapi.public%20kreta-mobile-global-webapi.public%20kreta-dkt-webapi.public%20kreta-ier-webapi.public&code_challenge=HByZRRnPGb-Ko_wTI7ibIba1HQ6lor0ws4bcgReuYSQ&redirect_uri=https://mobil.e-kreta.hu/ellenorzo-student/prod/oauthredirect&client_id=kreta-ellenorzo-student-mobile-ios&state=novynaplo'),
      );
  }

  @override
  Widget build(BuildContext context) {
    if (loadingPercentage < 100) {
      return Center(child: SpinKitPulsingGrid(color: Colors.lightBlueAccent));
    }
    return WebViewWidget(
      controller: controller,
    );
  }
}
