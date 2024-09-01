import 'package:flutter/material.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/ui/screens/login/kreta_oauth_webview.dart';

class NewLoginPage extends StatefulWidget {
  static String tag = 'login-page-new';
  const NewLoginPage({Key key}) : super(key: key);

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  Future<void> handleLogin(String code) async {
    print(code);
    final res = await RequestHandler.newLogin(code);
    print(res.status);
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );

    return Scaffold(
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            logo,
            SizedBox(height: 40.0),
            SizedBox(
              height: 500,
              width: MediaQuery.of(context).size.width,
              child: KretaOuathWebView(handleLogin),
            ),
          ],
        ),
      ),
    );
  }
}
