import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/marks_detail_tab.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/charts_tab.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/config.dart' as config;

var apiResponse = login.dJson;
var allParsedByDate, allParsedBySubject;
int selectedIndex = 0;
bool differenSubject = false;
String subjectBefore = "";
final List<Tab> markTabs = <Tab>[
  Tab(text: 'Dátum szerint', icon: Icon(Icons.calendar_today)),
  Tab(text: 'Tantárgy szerint', icon: Icon(Icons.view_list)),
];
String label, labelBefore;
TabController _tabController;

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static const title = 'Jegyek';
  static const androidIcon = Icon(Icons.music_note);

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  MarksTabState createState() => MarksTabState();
}

class MarksTabState extends State<MarksTab>
    with SingleTickerProviderStateMixin {
  int itemsLength = login.markCount;
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();
  final _androidRefreshKeyTwo = GlobalKey<RefreshIndicatorState>();

  List<MaterialColor> colors;
  List<String> markNameByDate;
  List<String> markNameBySubject;

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    _setData();
    super.initState();
  }

  @override
  void dispose() {
    adBanner.dispose();
    super.dispose();
  }

  void _setData() {
    colors = getRandomColors(itemsLength);
    markNameByDate = parseMarksByDate(apiResponse);
    allParsedByDate = parseAllByDate(apiResponse);
    markNameBySubject = parseMarksBySubject(apiResponse);
    allParsedBySubject = parseAllBySubject(apiResponse);
  }

  Future<void> _refreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => setState(() => _setData()),
    );
  }

  Widget _dateListBuilder(BuildContext context, int index) {
    if (index >= itemsLength) return null;
    final color = colors[index].shade400;
    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: HeroAnimatingMarksCard(
            title: markNameByDate[index],
            color: color,
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => SongDetailTab(
                    mode: allParsedByDate[index].mode,
                    theme: allParsedByDate[index].theme,
                    weight: allParsedByDate[index].weight,
                    date: allParsedByDate[index].date,
                    createDate: allParsedByDate[index].createDate,
                    teacher: allParsedByDate[index].teacher,
                    subject: allParsedByDate[index].subject,
                    numberValue: allParsedByDate[index].numberValue,
                    value: allParsedByDate[index].value,
                    formName: allParsedByDate[index].formName,
                    form: allParsedByDate[index].form,
                    id: index,
                    name: markNameByDate[index],
                    color: color,
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _subjectListBuilder(BuildContext context, int index) {
    if (index >= itemsLength) return null;
    final color = colors[index].shade400;
    if (subjectBefore != allParsedBySubject[index].subject) {
      subjectBefore = allParsedBySubject[index].subject;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return SizedBox(
          width: double.infinity,
          height: 135,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  capitalize(allParsedBySubject[index].subject) + ":",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Hero(
                    tag: index,
                    child: HeroAnimatingSubjectsCard(
                        title: markNameBySubject[index],
                        color: color,
                        heroAnimation: AlwaysStoppedAnimation(0),
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (context) => SongDetailTab(
                                mode: allParsedBySubject[index].mode,
                                theme: allParsedBySubject[index].theme,
                                weight: allParsedBySubject[index].weight,
                                date: allParsedBySubject[index].date,
                                createDate:
                                    allParsedBySubject[index].createDate,
                                teacher: allParsedBySubject[index].teacher,
                                subject: allParsedBySubject[index].subject,
                                numberValue:
                                    allParsedBySubject[index].numberValue,
                                value: allParsedBySubject[index].value,
                                formName: allParsedBySubject[index].formName,
                                form: allParsedBySubject[index].form,
                                id: index,
                                name: markNameBySubject[index],
                                color: color,
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          height: 135,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  capitalize(allParsedBySubject[index].subject) + ":",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Hero(
                    tag: index,
                    child: HeroAnimatingSubjectsCard(
                        title: markNameBySubject[index],
                        color: color,
                        heroAnimation: AlwaysStoppedAnimation(0),
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (context) => SongDetailTab(
                                mode: allParsedBySubject[index].mode,
                                theme: allParsedBySubject[index].theme,
                                weight: allParsedBySubject[index].weight,
                                date: allParsedBySubject[index].date,
                                createDate:
                                    allParsedBySubject[index].createDate,
                                teacher: allParsedBySubject[index].teacher,
                                subject: allParsedBySubject[index].subject,
                                numberValue:
                                    allParsedBySubject[index].numberValue,
                                value: allParsedBySubject[index].value,
                                formName: allParsedBySubject[index].formName,
                                form: allParsedBySubject[index].form,
                                id: index,
                                name: markNameBySubject[index],
                                color: color,
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return SizedBox(
        width: double.infinity,
        height: 106,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Hero(
            tag: index,
            child: HeroAnimatingSubjectsCard(
                title: markNameBySubject[index],
                color: color,
                heroAnimation: AlwaysStoppedAnimation(0),
                onPressed: () {
                  Navigator.of(context).push<void>(
                    MaterialPageRoute(
                      builder: (context) => SongDetailTab(
                        mode: allParsedBySubject[index].mode,
                        theme: allParsedBySubject[index].theme,
                        weight: allParsedBySubject[index].weight,
                        date: allParsedBySubject[index].date,
                        createDate: allParsedBySubject[index].createDate,
                        teacher: allParsedBySubject[index].teacher,
                        subject: allParsedBySubject[index].subject,
                        numberValue: allParsedBySubject[index].numberValue,
                        value: allParsedBySubject[index].value,
                        formName: allParsedBySubject[index].formName,
                        form: allParsedBySubject[index].form,
                        id: index,
                        name: markNameBySubject[index],
                        color: color,
                      ),
                    ),
                  );
                }),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    adBanner.load();
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
            /*ListTile(
              title: Text('Órarend'),
              leading: Icon(Icons.today),
              onTap: () {
                try {
                  Navigator.pushNamed(context, TimetableTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),*/
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
              leading: Icon(Icons.timeline),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: markTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: markTabs.map((Tab tab) {
            if (tab.text.toLowerCase() == "dátum szerint") {
              return RefreshIndicator(
                key: _androidRefreshKey,
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: login.markCount,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: _dateListBuilder,
                ),
              );
            }else{
              return RefreshIndicator(
                key: _androidRefreshKeyTwo,
                onRefresh: _refreshData,
                child: ListView.builder(
                  itemCount: login.markCount,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  itemBuilder: _subjectListBuilder,
                ),
              );
            }
          }).toList()),
    );
  }
}
