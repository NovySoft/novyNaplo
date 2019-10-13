import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cipher2/cipher2.dart';
import 'config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
var returnArray = ["","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""];

void loadEvent() async{
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String passKey = config.passKey;
  String codeKey = config.codeKey;
  String userKey = config.userKey;
  String iv = config.iv;
  String decryptedCode = await Cipher2.decryptAesCbc128Padding7(prefs.getString("code"), codeKey, iv);
  String decryptedUser = await Cipher2.decryptAesCbc128Padding7(prefs.getString("user"), userKey, iv);
  String decryptedPass = await Cipher2.decryptAesCbc128Padding7(prefs.getString("password"), passKey, iv);
  var url = 'https://novy.vip/api/grades.php?code=$decryptedCode&user=$decryptedUser&pass=$decryptedPass';
  var response = await http.get(url);
  if(response.statusCode == 200){
    returnArray = response.body.split(";");
  }else{
    returnArray[0] = "Error:"+response.statusCode.toString();
    //print('Response status: ${response.statusCode}');
  }
  if(returnArray.length < 20){
    while(returnArray.length < 20){
      returnArray.add("");
    }
  }  
}

class Marks extends StatelessWidget {
  static String tag = 'marks';
  
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NovyNotifier',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196f3),
        accentColor: const Color(0xFF2196f3),
        canvasColor: const Color(0xFFfafafa),
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    @override
    void initState() {
      super.initState();
      loadEvent();
    }

    @override
    Widget build(BuildContext context) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text('Jegyek'),
          ),
        body: new Scaffold(
            body:
              new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  new Text(
                  returnArray[0],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[1],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
                     
                  new Text(
                  returnArray[2],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[3],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[4],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[5],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[6],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
    
                  new Text(
                  returnArray[7],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[8],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[9],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[10],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[11],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[12],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[13],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[14],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),
                  
                  new Text(
                  returnArray[15],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[16],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[17],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  )/*,

                  new Text(
                  returnArray[18],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[19],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[20],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[21],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[22],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[23],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[24],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  ),

                  new Text(
                  returnArray[25],
                    style: new TextStyle(fontSize:32.0,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Roboto"),
                  )*/
                ]
    
              ),
    
          ),
    
      );
    }
}