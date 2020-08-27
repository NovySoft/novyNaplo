import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/timetable_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';

final List<Tab> days = <Tab>[
  Tab(text: getTranslatedString("monday")),
  Tab(text: getTranslatedString("tuesday")),
  Tab(text: getTranslatedString("wednesday")),
  Tab(text: getTranslatedString("thursday")),
  Tab(text: getTranslatedString("friday")),
  Tab(text: getTranslatedString("saturday")),
  Tab(text: getTranslatedString("sunday")),
];

List<List<Lesson>> lessonsList = [];
List<Color> colors = getRandomColors(15);
int matrixIndex = 0;

class TimetableTab extends StatefulWidget {
  static String tag = 'timetable';
  @override
  _TimetableTabState createState() => new _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    matrixIndex = 0;
    if (globals.payloadId != -1) {
      Lesson tempLesson;
      int tempindex;
      for (var n in lessonsList) {
        tempindex = n.indexWhere(
          (element) {
            return element.id == globals.payloadId;
          },
        );
        tempLesson = n.firstWhere(
          (element) {
            return element.id == globals.payloadId;
          },
          orElse: () {
            return new Lesson();
          },
        );
        if (tempLesson.id != null) {
          break;
        }
        matrixIndex++;
      }
      if (tempLesson.id != null)
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimetableDetailTab(
                icon: lessonsList[matrixIndex][tempindex].homework.icon,
                color: colors[tempindex],
                lessonInfo: lessonsList[matrixIndex][tempindex],
              ),
            ),
          );
        });
      globals.payloadId = -1;
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    globals.globalContext = context;
    return DefaultTabController(
      initialIndex: matrixIndex,
      length: 7,
      child: Scaffold(
          drawer: getDrawer(TimetableTab.tag, context),
          appBar: new AppBar(
            title: new Text(capitalize(getTranslatedString("timetable"))),
            bottom: TabBar(
              tabs: days,
            ),
          ),
          body: TabBarView(
              children: days.map((Tab tab) {
            String label = tab.text;
            //Itemcount globals.adModifier because we need one beacuse of the ads
            if (lessonsList.length == 0) {
              return noLesson();
            }
            if (label == getTranslatedString("monday")) {
              if (lessonsList[0].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[0].length + globals.adModifier,
                itemBuilder: _timetableBuilder,
              );
            } else if (label == getTranslatedString("tuesday")) {
              if (lessonsList[1].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[1].length + globals.adModifier,
                itemBuilder: _timetableTwoBuilder,
              );
            } else if (label == getTranslatedString("wednesday")) {
              if (lessonsList[2].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[2].length + globals.adModifier,
                itemBuilder: _timetableThreeBuilder,
              );
            } else if (label == getTranslatedString("thursday")) {
              if (lessonsList[3].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[3].length + globals.adModifier,
                itemBuilder: _timetableFourBuilder,
              );
            } else if (label == getTranslatedString("friday")) {
              if (lessonsList[4].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[4].length + globals.adModifier,
                itemBuilder: _timetableFiveBuilder,
              );
            } else if (label == getTranslatedString("saturday")) {
              if (lessonsList[5].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[5].length + globals.adModifier,
                itemBuilder: _timetableSixBuilder,
              );
            } else if (label == getTranslatedString("sunday")) {
              if (lessonsList[6].length == 0) {
                return noLesson();
              }
              return ListView.builder(
                itemCount: lessonsList[6].length + globals.adModifier,
                itemBuilder: _timetableSevenBuilder,
              );
            } else
              return Text("Error?");
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[0][index].homework.icon,
        hasHomework: lessonsList[0][index].homework.content != null,
        title: lessonsList[0][index].name,
        subTitle: subtitle, //lessonsList[0][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[0][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[0][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[1][index].homework.icon,
        hasHomework: lessonsList[1][index].homework.content != null,
        title: lessonsList[1][index].name,
        subTitle: subtitle, //lessonsList[1][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[1][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[1][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[2][index].homework.icon,
        hasHomework: lessonsList[2][index].homework.content != null,
        title: lessonsList[2][index].name,
        subTitle: subtitle, //lessonsList[2][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[2][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[2][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[3][index].homework.icon,
        hasHomework: lessonsList[3][index].homework.content != null,
        title: lessonsList[3][index].name,
        subTitle: subtitle, //lessonsList[3][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[3][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[3][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[4][index].homework.icon,
        hasHomework: lessonsList[4][index].homework.content != null,
        title: lessonsList[4][index].name,
        subTitle: subtitle, //lessonsList[4][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[4][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[4][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[5][index].homework.icon,
        hasHomework: lessonsList[5][index].homework.content != null,
        title: lessonsList[5][index].name,
        subTitle: subtitle, //lessonsList[5][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[5][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[5][index],
        ),
      ),
    );
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
      subtitle = "$diff ${getTranslatedString("min")}";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = getTranslatedString("unkown");
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
      child: TimetableCard(
        iconData: lessonsList[6][index].homework.icon,
        hasHomework: lessonsList[6][index].homework.content != null,
        title: lessonsList[6][index].name,
        subTitle: subtitle, //lessonsList[6][index].classroom,
        color: colors[index],
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: TimetableDetailTab(
          icon: lessonsList[6][index].homework.icon,
          color: colors[index],
          lessonInfo: lessonsList[6][index],
        ),
      ),
    );
  }
}

Widget noLesson() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          MdiIcons.emoticonHappyOutline,
          size: 50,
        ),
        Text("${getTranslatedString("noLesson")}!")
      ],
    ),
  );
}
