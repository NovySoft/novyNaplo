import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'login_page.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/avarages_tab.dart';

import 'marks_detail_tab.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/charts_tab.dart';

SharedPreferences prefs;
var apiResponse = dJson;
var allParsed;

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static const title = 'Jegyek';
  static const androidIcon = Icon(Icons.music_note);

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _MarksTabState createState() => _MarksTabState();
}

class _MarksTabState extends State<MarksTab> {
  int itemsLength = markCount;
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  List<MaterialColor> colors;
  List<String> markName;

  @override
  void initState() {
    _setData();
    super.initState();
  }

  void _setData() {
    colors = getRandomColors(itemsLength);
    markName = parseMarks(apiResponse);
    allParsed = parseAll(apiResponse);
  }

  Future<void> _refreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => setState(() => _setData()),
    );
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= itemsLength) return null;
    final color = colors[index].shade400;

    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: HeroAnimatingSongCard(
            song: markName[index],
            color: color,
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => SongDetailTab(
                    mode: allParsed[index].mode,
                    theme: allParsed[index].theme,
                    weight: allParsed[index].weight,
                    date: allParsed[index].date,
                    createDate: allParsed[index].createDate,
                    teacher: allParsed[index].teacher,
                    subject: allParsed[index].subject,
                    numberValue: allParsed[index].numberValue,
                    value: allParsed[index].value,
                    formName: allParsed[index].formName,
                    form: allParsed[index].form,
                    id: index,
                    name: markName[index],
                    color: color,
                  ),
                ),
              );
            }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                // Update the state of the app.
                Navigator.pop(context);
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
                try {
                  Navigator.pushNamed(context, ChartsTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
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
      appBar: AppBar(
        title: Text(MarksTab.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async => await _androidRefreshKey.currentState.show(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _androidRefreshKey,
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: markCount,
          padding: EdgeInsets.symmetric(vertical: 12),
          itemBuilder: _listBuilder,
        ),
      ),
    );
  }
}
