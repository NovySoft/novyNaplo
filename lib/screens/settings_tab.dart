import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/functions/colorManager.dart';
import 'package:novynaplo/config.dart';

String dropDown;

class SettingsTab extends StatefulWidget {
  static String tag = 'settings';
  static const title = 'Beállítások';

  const SettingsTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsTab.title),
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
                try {
                  Navigator.pushNamed(context, NoticesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Beállítások'),
              leading: Icon(Icons.settings_applications),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: MyStatefulWidget(),
    );
  }
}

//TODO RENAME CLASSES
class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);

  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      dropDown = "Világos";
    } else {
      dropDown = "Sötét";
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 1,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text("Téma:"),
          trailing: DropdownButton<String>(
            items: [
              DropdownMenuItem(
                value: "Sötét",
                child: Text(
                  "Sötét",
                ),
              ),
              DropdownMenuItem(
                value: "Világos",
                child: Text(
                  "Világos",
                ),
              ),
            ],
            onChanged: (String value) {
              if(value == "Világos"){
                ColorManager().changeBrightness(context,Brightness.light);
                FirebaseAnalytics().setUserProperty(name: "Theme",value: "Bright");
              }else{
                ColorManager().changeBrightness(context,Brightness.dark);
                FirebaseAnalytics().setUserProperty(name: "Theme",value: "Dark");
              }
              setState(() {
                dropDown = value;
              });
            },
            value: dropDown,
          ),
        );
      },
    );
  }
}
