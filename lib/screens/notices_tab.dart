import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/functions/colorManager.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
var allParsedNotices;



class NoticesTab extends StatefulWidget {
  static String tag = 'notices';
  static const title = 'Feljegyzések';

  @override
  _NoticesTabState createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(NoticesTab.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child:
                    Center(child: new Image.asset(menuLogo, fit: BoxFit.fill))),
            ListTile(
              title: Text('Jegyek'),
              leading: Icon(Icons.create),
              onTap: () {
                try {
                  Navigator.pushNamed(context, MarksTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Átlagok'),
              leading: Icon(Icons.all_inclusive),
              onTap: () {
                try {
                  Navigator.pushNamed(context, AvaragesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Feljegyzések'),
              leading: Icon(Icons.layers),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Beállítások'),
              leading: Icon(Icons.settings_applications),
              onTap: () {
                try {
                  Navigator.pushNamed(context, SettingsTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: noticesCount,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _noticesBuilder,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }
}

Widget _noticesBuilder(BuildContext context, int index) {
  return SafeArea(
    top: false,
    bottom: false,
    child: AnimatedNoticesCard(title: allParsedNotices[index].title,subTitle: allParsedNotices[index].teacher,color: getRandomColors(1)[0],heroAnimation: AlwaysStoppedAnimation(0)),
  );
}

void onInit(){
  //TODO write this function
}