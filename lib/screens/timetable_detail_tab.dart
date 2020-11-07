import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/helpers/functions/capitalize.dart';
import 'package:novynaplo/helpers/functions/parseSubjectToIcon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';

Timer timer;

class TimetableDetailTab extends StatefulWidget {
  const TimetableDetailTab({this.lessonInfo, this.color, @required this.icon});

  final Lesson lessonInfo;
  final Color color;
  final IconData icon;

  @override
  _TimetableDetailTabState createState() => _TimetableDetailTabState();
}

class _TimetableDetailTabState extends State<TimetableDetailTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Timetable_detail_tab");
    super.initState();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
    super.dispose();
  }

  Widget _buildBody() {
    IconData icon = widget.icon;
    //!This is stupid, but this is the only way it works
    if (widget.icon == null || icon == null) {
      icon = parseSubjectToIcon(subject: widget.lessonInfo.subject);
    }
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            stretch: true,
            title: new Container(),
            leading: new Container(),
            backgroundColor: widget.color,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: [StretchMode.zoomBackground],
              background: Icon(
                icon,
                size: 150,
                color: Colors.black38,
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              switch (index) {
                case 0:
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                    child: Text(
                      '${getTranslatedString("lessonInfo")}:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                  break;
                case 1:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("nameOfLesson")}: " +
                            widget.lessonInfo.name,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 3:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("themeOfLesson")}: " +
                            widget.lessonInfo.theme,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 5:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("subject")}: " +
                            widget.lessonInfo.subject,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 7:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("classroom")}: " +
                            widget.lessonInfo.classroom,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 9:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("teacher")}: " +
                            widget.lessonInfo.teacher,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 11:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("deputTeacher")}: " +
                            widget.lessonInfo.deputyTeacherName,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 13:
                  String date = widget.lessonInfo.date.year.toString() +
                      "-" +
                      widget.lessonInfo.date.month.toString() +
                      "-" +
                      widget.lessonInfo.date.day.toString();
                  return SizedBox(
                    child: Text("${getTranslatedString("date")}: " + date,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 15:
                  String startMinutes;
                  if (widget.lessonInfo.startDate.minute
                      .toString()
                      .startsWith("0")) {
                    startMinutes =
                        widget.lessonInfo.startDate.minute.toString() + "0";
                  } else {
                    startMinutes =
                        widget.lessonInfo.startDate.minute.toString();
                  }
                  String endMinutes;
                  if (widget.lessonInfo.endDate.minute
                      .toString()
                      .startsWith("0")) {
                    endMinutes =
                        widget.lessonInfo.endDate.minute.toString() + "0";
                  } else {
                    endMinutes = widget.lessonInfo.endDate.minute.toString();
                  }
                  String start = widget.lessonInfo.startDate.hour.toString() +
                      ":" +
                      startMinutes;
                  String end = widget.lessonInfo.endDate.hour.toString() +
                      ":" +
                      endMinutes;
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("startStop")}: " +
                            start +
                            " - " +
                            end,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 17:
                  Duration diff = widget.lessonInfo.endDate
                      .difference(widget.lessonInfo.startDate);
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("period")}: " +
                            diff.inMinutes.toString() +
                            " perc",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 19:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("class")}: " +
                            widget.lessonInfo.groupName,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 21:
                  if (widget.lessonInfo.teacherHomework.content == null) {
                    return SizedBox(
                      child: Text(
                          "${capitalize(getTranslatedString("hw"))}: ${getTranslatedString("nothing").toUpperCase()}",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                  } else {
                    return SizedBox(
                        child: Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 18),
                          Text("${capitalize(getTranslatedString("hw"))}: ",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Html(
                            data: widget.lessonInfo.teacherHomework.content,
                            onLinkTap: (url) async {
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                FirebaseAnalytics().logEvent(
                                  name: "LinkFail",
                                  parameters: {"link": url},
                                );
                                throw 'Could not launch $url';
                              }
                            },
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ));
                  }
                  break;
                case 23:
                  if (widget.lessonInfo.teacherHomework.content == null) {
                    return SizedBox(height: 18);
                  } else {
                    String due = widget.lessonInfo.teacherHomework.dueDate.year
                            .toString() +
                        "-" +
                        widget.lessonInfo.teacherHomework.dueDate.month
                            .toString() +
                        "-" +
                        widget.lessonInfo.teacherHomework.dueDate.day
                            .toString() +
                        " " +
                        widget.lessonInfo.teacherHomework.dueDate.hour
                            .toString() +
                        ":" +
                        widget.lessonInfo.teacherHomework.dueDate.minute
                            .toString();
                    Duration left = widget.lessonInfo.teacherHomework.dueDate
                        .difference(DateTime.now());
                    String leftHours = (left.inMinutes / 60).toStringAsFixed(0);
                    String leftMins = (left.inMinutes % 60).toStringAsFixed(0);
                    String leftString =
                        "$leftHours ${getTranslatedString("yHrs")} ${getTranslatedString("and")} $leftMins ${getTranslatedString("yMins")}";
                    bool dueOver = false;
                    if (left.inMinutes / 60 < 0) {
                      dueOver = true;
                    }
                    timer =
                        new Timer.periodic(new Duration(minutes: 1), (time) {
                      if (!mounted) {
                        timer.cancel();
                      } else {
                        setState(() {
                          left = widget.lessonInfo.teacherHomework.dueDate
                              .difference(DateTime.now());
                          leftHours = (left.inMinutes / 60).toStringAsFixed(0);
                          leftMins = (left.inMinutes % 60).toStringAsFixed(0);
                          leftString =
                              "$leftHours ${getTranslatedString("yHrs")} ${getTranslatedString("and")} $leftMins ${getTranslatedString("yMins")}";
                          if (left.inMinutes / 60 < 0) {
                            dueOver = true;
                          } else {
                            dueOver = false;
                          }
                        });
                      }
                    });
                    if (dueOver) {
                      return SizedBox(
                        child: Text(
                            "${getTranslatedString("hDue")}: " +
                                due +
                                " (${getTranslatedString("overDue")})",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      );
                    } else {
                      return SizedBox(
                        child: Text(
                            "${getTranslatedString("hDue")}: " +
                                due +
                                " (${getTranslatedString("hLeft")}: $leftString)",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    }
                  }
                  break;
                case 24:
                  return SizedBox(
                    height: 250,
                  );
                  break;
                default:
                  return SizedBox(height: 10);
              }
            }, childCount: 25),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(title: Text(widget.lessonInfo.name)),
      body: _buildBody(),
    );
  }
}
