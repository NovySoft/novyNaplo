import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_page.dart';
import 'marks_tab.dart';

void main() async {
  runApp(MyApp());
  Map<PermissionGroup, PermissionStatus> permissions =
      await PermissionHandler().requestPermissions([PermissionGroup.contacts]);
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
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.black),
          ),
          brightness: Brightness.light,
          primarySwatch: Colors.lightBlue,
          buttonColor: Colors.lightBlueAccent,
          primaryColor: Colors.lightBlueAccent,
          backgroundColor: Colors.green,
          fontFamily: 'Nunito',
          colorScheme: ColorScheme.light(),
          hintColor: Colors.lightBlue,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.blueAccent,
            ),
            fillColor: Colors.black,
            hintStyle: TextStyle(color: Colors.black),
            focusColor: Colors.orange,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          )),
      darkTheme: ThemeData(
          textTheme: TextTheme(
            subhead: TextStyle(color: Colors.orange),
          ),
          buttonColor: Colors.orange,
          backgroundColor: Colors.black,
          primarySwatch: Colors.orange,
          primaryColor: Colors.orange,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(),
          hintColor: Colors.red,
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              color: Colors.black,
            ),
            fillColor: Colors.black,
            hintStyle: TextStyle(color: Colors.orange),
            focusColor: Colors.orange,
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
          )),
      home: LoginPage(),
      routes: routes,
    );
  }
}
