import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/timetable_detail_tab.dart';

import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/charts_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/screens/calculator_tab.dart';

final List<Tab> days = <Tab>[
  Tab(text: 'Hétfő'),
  Tab(text: 'Kedd'),
  Tab(text: 'Szerda'),
  Tab(text: 'Csütörtök'),
  Tab(text: 'Péntek'),
  Tab(text: 'Szombat'),
  Tab(text: 'Vasárnap'),
];

List<List<Lesson>> lessonsList;
List<MaterialColor> colors = getRandomColors(15);

class TimetableTab extends StatefulWidget {
  static String tag = 'timetable';
  @override
  _TimetableTabState createState() => new _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                    decoration: BoxDecoration(color: Colors.grey),
                    child: Center(
                        child: new Image.asset(menuLogo, fit: BoxFit.fill))),
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
                  title: Text('Órarend'),
                  leading: Icon(Icons.today),
                  onTap: () {
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
                  title: Text('Jegyszámoló'),
                  leading: new Icon(MdiIcons.calculator),
                  onTap: () {
                    try {
                      Navigator.pushNamed(context, CalculatorTab.tag);
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
          appBar: new AppBar(
            title: new Text("Órarend"),
            bottom: TabBar(
              tabs: days,
            ),
          ),
          body: TabBarView(
              children: days.map((Tab tab) {
            String label = tab.text;
            //Itemcount + 1 because we need one beacuse of the ads
            if (label == "Hétfő") {
              return ListView.builder(
                itemCount: lessonsList[0].length + 1,
                itemBuilder: _timetableBuilder,
              );
            } else if (label == "Kedd") {
              return ListView.builder(
                itemCount: lessonsList[1].length + 1,
                itemBuilder: _timetableTwoBuilder,
              );
            } else if (label == "Szerda") {
              return ListView.builder(
                itemCount: lessonsList[2].length + 1,
                itemBuilder: _timetableThreeBuilder,
              );
            } else if (label == "Csütörtök") {
              return ListView.builder(
                itemCount: lessonsList[3].length + 1,
                itemBuilder: _timetableFourBuilder,
              );
            } else if (label == "Péntek") {
              return ListView.builder(
                itemCount: lessonsList[4].length + 1,
                itemBuilder: _timetableFiveBuilder,
              );
            } else if (label == "Szombat") {
              return ListView.builder(
                itemCount: lessonsList[5].length + 1,
                itemBuilder: _timetableSixBuilder,
              );
            } else if (label == "Vasárnap") {
              return ListView.builder(
                itemCount: lessonsList[6].length + 1,
                itemBuilder: _timetableSevenBuilder,
              );
            } else
              return Text("Mi van?");
          }).toList())),
    );
  }
}

Widget _timetableBuilder(BuildContext context, int index) {
  if (index >= lessonsList[0].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[0][index].name,
            subTitle: lessonsList[0][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[0][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableTwoBuilder(BuildContext context, int index) {
  if (index >= lessonsList[1].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[1][index].name,
            subTitle: lessonsList[1][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[1][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableThreeBuilder(BuildContext context, int index) {
  if (index >= lessonsList[2].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[2][index].name,
            subTitle: lessonsList[2][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[2][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableFourBuilder(BuildContext context, int index) {
  if (index >= lessonsList[3].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[3][index].name,
            subTitle: lessonsList[3][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[3][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableFiveBuilder(BuildContext context, int index) {
  if (index >= lessonsList[4].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[4][index].name,
            subTitle: lessonsList[4][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[4][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableSixBuilder(BuildContext context, int index) {
  if (index >= lessonsList[5].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[5][index].name,
            subTitle: lessonsList[5][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[5][index],
                  ),
                ),
              );
            }));
  }
}

Widget _timetableSevenBuilder(BuildContext context, int index) {
  if (index >= lessonsList[6].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[6][index].name,
            subTitle: lessonsList[6][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (context) => TimetableDetailTab(
                    color: colors[index],
                    lessonInfo: lessonsList[6][index],
                  ),
                ),
              );
            }));
  }
}
