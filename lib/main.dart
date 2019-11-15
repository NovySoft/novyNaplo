import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_page.dart';
import 'marks_tab.dart';

void main() async{
  runApp(MyApp());
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
}

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Novy Napló',
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
