import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_page.dart';
import 'marks.dart';

void main() async{
  runApp(MyApp());
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    Marks.tag: (context) => Marks(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovyNotifier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        fontFamily: 'Nunito',
      ),
      home: LoginPage(),
      routes: routes,
    );
  }
}
