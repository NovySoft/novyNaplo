import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/charts_detail_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
var allParsedSubjects;
var colors;


class ChartsTab extends StatefulWidget {
  static String tag = 'charts';
  static const title = 'Grafikonok';

  @override
  _ChartsTabState createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(ChartsTab.title),
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
              title: Text('Grafikonok'),
              leading: Icon(Icons.multiline_chart),
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
        itemCount: allParsedSubjects.length,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _chartsListBuilder,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}

Widget _chartsListBuilder(BuildContext context, int index) {
  MaterialColor currColor = colors[index];
  List<int> currSubjectMarks = [];
  for(var n in allParsedSubjects[index]){
    currSubjectMarks.add(int.parse(n.split(":")[1]));
  }
  return SafeArea(
    top: false,
    bottom: false,
    child: AnimatedChartsCard(
        title: capitalize(allParsedSubjects[index][0].split(":")[0]),
        color: currColor,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (context) => ChartsDetailTab(
              id: index,
              subject: capitalize(allParsedSubjects[index][0].split(":")[0]),
              color: currColor,
              seriesList: createSubjectChart(currSubjectMarks,index.toString()),
              animate: true,
            ),
          ),
        );
      })
  );
}