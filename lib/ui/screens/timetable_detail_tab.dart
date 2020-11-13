import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/style.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

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
                        "${getTranslatedString("nameOfLesson")}: ${widget.lessonInfo.nev != null ? widget.lessonInfo.nev : ""}",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 3:
                  return SizedBox(
                    child: Text(
                      "${getTranslatedString("themeOfLesson")}: ${widget.lessonInfo.tema != null ? widget.lessonInfo.tema : getTranslatedString("unkown")}",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  );
                  break;
                case 5:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("subject")}: ${widget.lessonInfo.tantargy.nev != null ? widget.lessonInfo.tantargy.nev : ""}",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 7:
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("classroom")}: ${widget.lessonInfo.teremNeve != null ? widget.lessonInfo.teremNeve : ""}",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 9:
                  if (widget.lessonInfo.helyettesTanarNeve != null) {
                    return SizedBox(
                      child: Row(
                        children: [
                          Text(
                            "${getTranslatedString("deputyTeacher")}: ",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "${widget.lessonInfo.helyettesTanarNeve}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return SizedBox(
                      child: Text(
                          "${getTranslatedString("teacher")}: ${widget.lessonInfo.tanarNeve != null ? widget.lessonInfo.tanarNeve : ""}",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                  }
                  break;
                case 11:
                  if (widget.lessonInfo.datum != null) {
                    String date = widget.lessonInfo.datum.year.toString() +
                        "-" +
                        widget.lessonInfo.datum.month.toString() +
                        "-" +
                        widget.lessonInfo.datum.day.toString();
                    return SizedBox(
                      child: Text("${getTranslatedString("date")}: $date",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                  } else {
                    return SizedBox(height: 0, width: 0);
                  }
                  break;
                case 13:
                  if (widget.lessonInfo.kezdetIdopont == null ||
                      widget.lessonInfo.vegIdopont == null) {
                    return SizedBox(height: 0, width: 0);
                  }
                  String startMinutes;
                  if (widget.lessonInfo.kezdetIdopont.minute
                      .toString()
                      .startsWith("0")) {
                    startMinutes =
                        widget.lessonInfo.kezdetIdopont.minute.toString() + "0";
                  } else {
                    startMinutes =
                        widget.lessonInfo.kezdetIdopont.minute.toString();
                  }
                  String endMinutes;
                  if (widget.lessonInfo.vegIdopont.minute
                      .toString()
                      .startsWith("0")) {
                    endMinutes =
                        widget.lessonInfo.vegIdopont.minute.toString() + "0";
                  } else {
                    endMinutes = widget.lessonInfo.vegIdopont.minute.toString();
                  }
                  String start =
                      widget.lessonInfo.kezdetIdopont.hour.toString() +
                          ":" +
                          startMinutes;
                  String end = widget.lessonInfo.vegIdopont.hour.toString() +
                      ":" +
                      endMinutes;
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("startStop")}: $start - $end",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 15:
                  if (widget.lessonInfo.kezdetIdopont == null ||
                      widget.lessonInfo.vegIdopont == null) {
                    return SizedBox(height: 0, width: 0);
                  }
                  Duration diff = widget.lessonInfo.vegIdopont
                      .difference(widget.lessonInfo.kezdetIdopont);
                  return SizedBox(
                    child: Text(
                        "${getTranslatedString("period")}: ${diff.inMinutes.toString()} ${getTranslatedString("minutes")}",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 17:
                  return widget.lessonInfo.osztalyCsoport.nev != null
                      ? SizedBox(
                          child: Text(
                              "${getTranslatedString("class")}: ${widget.lessonInfo.osztalyCsoport.nev}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        )
                      : SizedBox(height: 0, width: 0);
                  break;
                case 19:
                  if (!((widget.lessonInfo.haziFeladatUid != null &&
                          widget.lessonInfo.haziFeladatUid != "") ||
                      (widget.lessonInfo.bejelentettSzamonkeresek.length !=
                          0))) {
                    return SizedBox(height: 0, width: 0);
                  }
                  if (((widget.lessonInfo.haziFeladatUid != null &&
                          widget.lessonInfo.haziFeladatUid != "") &&
                      (widget.lessonInfo.bejelentettSzamonkeresek.length !=
                          0))) {
                    String due = widget
                            .lessonInfo.haziFeladat.hataridoDatuma.year
                            .toString() +
                        "-" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.month
                            .toString() +
                        "-" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.day
                            .toString() +
                        " " +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.hour
                            .toString() +
                        ":" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.minute
                            .toString();
                    Duration left = widget.lessonInfo.haziFeladat.hataridoDatuma
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
                          left = widget.lessonInfo.haziFeladat.hataridoDatuma
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
                    return SizedBox(
                        child: Center(
                      child: Column(
                        children: <Widget>[
                          Text(
                            "${capitalize(getTranslatedString("thisLessonsExams"))}: ",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Html(
                                    data:
                                        "${widget.lessonInfo.bejelentettSzamonkeresek[index].modja.leiras}: ${widget.lessonInfo.bejelentettSzamonkeresek[index].tema}",
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
                                  SizedBox(
                                    height: 5,
                                    width: 5,
                                  ),
                                ],
                              );
                            },
                            itemCount: widget
                                .lessonInfo.bejelentettSzamonkeresek.length,
                          ),
                          SizedBox(height: 18),
                          Text("${capitalize(getTranslatedString("hw"))}: ",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Html(
                            data: widget.lessonInfo.haziFeladat.szoveg,
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
                          SizedBox(height: 18),
                          (dueOver)
                              ? SizedBox(
                                  child: Text(
                                    "${getTranslatedString("hDue")}: " +
                                        due +
                                        " (${getTranslatedString("overDue")})",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                )
                              : SizedBox(
                                  child: Text(
                                    "${getTranslatedString("hDue")}: " +
                                        due +
                                        " (${getTranslatedString("hLeft")}: $leftString)",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ],
                      ),
                    ));
                  }

                  if (widget.lessonInfo.haziFeladatUid != null &&
                      widget.lessonInfo.haziFeladatUid != "") {
                    String due = widget
                            .lessonInfo.haziFeladat.hataridoDatuma.year
                            .toString() +
                        "-" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.month
                            .toString() +
                        "-" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.day
                            .toString() +
                        " " +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.hour
                            .toString() +
                        ":" +
                        widget.lessonInfo.haziFeladat.hataridoDatuma.minute
                            .toString();
                    Duration left = widget.lessonInfo.haziFeladat.hataridoDatuma
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
                          left = widget.lessonInfo.haziFeladat.hataridoDatuma
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

                    return SizedBox(
                        child: Center(
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 18),
                          Text("${capitalize(getTranslatedString("hw"))}: ",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold)),
                          Html(
                            data: widget.lessonInfo.haziFeladat.szoveg,
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
                          SizedBox(height: 18),
                          (dueOver)
                              ? SizedBox(
                                  child: Text(
                                    "${getTranslatedString("hDue")}: " +
                                        due +
                                        " (${getTranslatedString("overDue")})",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                )
                              : SizedBox(
                                  child: Text(
                                    "${getTranslatedString("hDue")}: " +
                                        due +
                                        " (${getTranslatedString("hLeft")}: $leftString)",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        ],
                      ),
                    ));
                  }
                  if (widget.lessonInfo.bejelentettSzamonkeresek.length != 0) {
                    return SizedBox(
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(height: 18),
                            Text(
                              "${capitalize(getTranslatedString("thisLessonsExams"))}: ",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Html(
                                      data:
                                          "${widget.lessonInfo.bejelentettSzamonkeresek[index].modja.leiras}: ${widget.lessonInfo.bejelentettSzamonkeresek[index].tema}",
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
                                    SizedBox(
                                      height: 5,
                                      width: 5,
                                    ),
                                  ],
                                );
                              },
                              itemCount: widget
                                  .lessonInfo.bejelentettSzamonkeresek.length,
                            ),
                          ],
                        ),
                      ),
                    );
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
      appBar: AppBar(title: Text(widget.lessonInfo.nev)),
      body: _buildBody(),
    );
  }
}
