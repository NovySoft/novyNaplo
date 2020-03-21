import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/timetable_detail_tab.dart';
//import 'package:novynaplo/screens/globals_page.dart' as globals;
import 'package:novynaplo/global.dart' as globals;

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
List<Color> colors = getRandomColors(15);

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
          drawer: getDrawer(TimetableTab.tag, context),
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[0].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[0][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[0][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[0][index].teacher != null ||
          lessonsList[0][index].teacher != "") {
        subtitle = lessonsList[0][index].teacher;
      } else {
        subtitle = lessonsList[0][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[0][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[0][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[0][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[0][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[0][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[0][index].endDate.minute.toString();
      }
      String start =
          lessonsList[0][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[0][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[0][index]
          .endDate
          .difference(lessonsList[0][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[0].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[0][index].name,
            subTitle: subtitle, //lessonsList[0][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[1].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[1][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[1][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[1][index].teacher != null ||
          lessonsList[1][index].teacher != "") {
        subtitle = lessonsList[1][index].teacher;
      } else {
        subtitle = lessonsList[1][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[1][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[1][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[1][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[1][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[1][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[1][index].endDate.minute.toString();
      }
      String start =
          lessonsList[1][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[1][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[1][index]
          .endDate
          .difference(lessonsList[1][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[1].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[1][index].name,
            subTitle: subtitle,//lessonsList[1][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[2].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[2][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[2][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[2][index].teacher != null ||
          lessonsList[2][index].teacher != "") {
        subtitle = lessonsList[2][index].teacher;
      } else {
        subtitle = lessonsList[2][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[2][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[2][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[2][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[2][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[2][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[2][index].endDate.minute.toString();
      }
      String start =
          lessonsList[2][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[2][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[2][index]
          .endDate
          .difference(lessonsList[2][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[2].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[2][index].name,
            subTitle: subtitle,//lessonsList[2][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[3].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[3][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[3][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[3][index].teacher != null ||
          lessonsList[3][index].teacher != "") {
        subtitle = lessonsList[3][index].teacher;
      } else {
        subtitle = lessonsList[3][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[3][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[3][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[3][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[3][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[3][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[3][index].endDate.minute.toString();
      }
      String start =
          lessonsList[3][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[3][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[3][index]
          .endDate
          .difference(lessonsList[3][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[3].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[3][index].name,
            subTitle: subtitle,//lessonsList[3][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[4].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[4][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[4][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[4][index].teacher != null ||
          lessonsList[4][index].teacher != "") {
        subtitle = lessonsList[4][index].teacher;
      } else {
        subtitle = lessonsList[4][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[4][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[4][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[4][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[4][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[4][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[4][index].endDate.minute.toString();
      }
      String start =
          lessonsList[4][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[4][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[4][index]
          .endDate
          .difference(lessonsList[4][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[4].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[4][index].name,
            subTitle: subtitle,//lessonsList[4][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[5].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[5][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[5][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[5][index].teacher != null ||
          lessonsList[5][index].teacher != "") {
        subtitle = lessonsList[5][index].teacher;
      } else {
        subtitle = lessonsList[5][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[5][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[5][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[5][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[5][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[5][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[5][index].endDate.minute.toString();
      }
      String start =
          lessonsList[5][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[5][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[5][index]
          .endDate
          .difference(lessonsList[5][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[5].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[5][index].name,
            subTitle: subtitle,//lessonsList[5][index].classroom,
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
  String subtitle = "undefined";
  if (!(index >= lessonsList[6].length)) {
    if (globals.lessonCardSubtitle == "Tanterem") {
      subtitle = lessonsList[6][index].classroom;
    } else if (globals.lessonCardSubtitle == "Óra témája") {
      subtitle = lessonsList[6][index].theme;
    } else if (globals.lessonCardSubtitle == "Tanár") {
      if (lessonsList[6][index].teacher != null ||
          lessonsList[6][index].teacher != "") {
        subtitle = lessonsList[6][index].teacher;
      } else {
        subtitle = lessonsList[6][index].deputyTeacherName;
      }
    } else if (globals.lessonCardSubtitle == "Kezdés-Bejezés") {
      String startMinutes;
      if (lessonsList[6][index].startDate.minute.toString().startsWith("0")) {
        startMinutes = lessonsList[6][index].startDate.minute.toString() + "0";
      } else {
        startMinutes = lessonsList[6][index].startDate.minute.toString();
      }
      String endMinutes;
      if (lessonsList[6][index].endDate.minute.toString().startsWith("0")) {
        endMinutes = lessonsList[6][index].endDate.minute.toString() + "0";
      } else {
        endMinutes = lessonsList[6][index].endDate.minute.toString();
      }
      String start =
          lessonsList[6][index].startDate.hour.toString() + ":" + startMinutes;
      String end =
          lessonsList[6][index].endDate.hour.toString() + ":" + endMinutes;
      subtitle = "$start-$end";
    } else if (globals.lessonCardSubtitle == "Időtartam") {
      String diff = lessonsList[6][index]
          .endDate
          .difference(lessonsList[6][index].startDate)
          .inMinutes
          .toString();
      subtitle = "$diff perc";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 28) {
      subtitle = subtitle.substring(0, 25);
      subtitle += "...";
    }
  }
  if (index >= lessonsList[6].length) {
    return SizedBox(height: 100);
  } else {
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
            title: lessonsList[6][index].name,
            subTitle: subtitle,//lessonsList[6][index].classroom,
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
