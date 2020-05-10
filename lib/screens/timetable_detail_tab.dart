import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;

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
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroAnimatingMarksCard(
            eval: null,
            iconData: icon,
            subTitle: "",
            title: widget.lessonInfo.name,
            color: widget.color,
            heroAnimation: AlwaysStoppedAnimation(1),
          ),
          Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                      child: Text(
                        'Óra információk:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                    break;
                  case 1:
                    return SizedBox(
                      child: Text("Az óra neve: " + widget.lessonInfo.name,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 2:
                    return SizedBox(
                      child: Text("Óra témája: " + widget.lessonInfo.theme,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 3:
                    return SizedBox(
                      child: Text("Tantárgy: " + widget.lessonInfo.subject,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 4:
                    return SizedBox(
                      child: Text("Terem: " + widget.lessonInfo.classroom,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 5:
                    return SizedBox(
                      child: Text("Tanár: " + widget.lessonInfo.teacher,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 6:
                    return SizedBox(
                      child: Text(
                          "Helyettesítő Tanár (ha van): " +
                              widget.lessonInfo.deputyTeacherName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 7:
                    String date = widget.lessonInfo.date.year.toString() +
                        "-" +
                        widget.lessonInfo.date.month.toString() +
                        "-" +
                        widget.lessonInfo.date.day.toString();
                    return SizedBox(
                      child: Text("Dátum: " + date,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 8:
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
                      child: Text("Kezdés-befejezés: " + start + " - " + end,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 9:
                    Duration diff = widget.lessonInfo.endDate
                        .difference(widget.lessonInfo.startDate);
                    return SizedBox(
                      child: Text(
                          "Időtartam: " + diff.inMinutes.toString() + " perc",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 10:
                    return SizedBox(
                      child: Text("Osztály: " + widget.lessonInfo.groupName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 11:
                    if (widget.lessonInfo.homework.content == null) {
                      return SizedBox(
                        child: Text("Házifeladat: NINCS",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    } else {
                      return SizedBox(
                          child: Center(
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 18),
                            Text("Házifeladat: ",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold)),
                            Html(
                              data: widget.lessonInfo.homework.content,
                              customTextStyle:
                                  (dom.Node node, TextStyle baseStyle) {
                                if (node is dom.Element) {
                                  return baseStyle
                                      .merge(TextStyle(fontSize: 20));
                                }
                                return baseStyle;
                              },
                              onLinkTap: (url) async {
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  FirebaseAnalytics()
                                      .logEvent(name: "LinkFail");
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
                  case 12:
                    if (widget.lessonInfo.homework.content == null) {
                      return SizedBox(height: 18);
                    } else {
                      String due = widget.lessonInfo.homework.dueDate.year
                              .toString() +
                          "-" +
                          widget.lessonInfo.homework.dueDate.month.toString() +
                          "-" +
                          widget.lessonInfo.homework.dueDate.day.toString() +
                          " " +
                          widget.lessonInfo.homework.dueDate.hour.toString() +
                          ":" +
                          widget.lessonInfo.homework.dueDate.minute.toString();
                      Duration left = widget.lessonInfo.homework.dueDate
                          .difference(DateTime.now());
                      String leftHours =
                          (left.inMinutes / 60).toStringAsFixed(0);
                      String leftMins =
                          (left.inMinutes % 60).toStringAsFixed(0);
                      String leftString = "$leftHours órád és $leftMins perced";
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
                            left = widget.lessonInfo.homework.dueDate
                                .difference(DateTime.now());
                            leftHours =
                                (left.inMinutes / 60).toStringAsFixed(0);
                            leftMins = (left.inMinutes % 60).toStringAsFixed(0);
                            leftString = "$leftHours órád és $leftMins perced";
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
                              "Házifeladat határideje: " +
                                  due +
                                  " (határidőn túl)",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      } else {
                        return SizedBox(
                          child: Text(
                              "Házifeladat határideje: " +
                                  due +
                                  " (van még: $leftString)",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                        );
                      }
                    }
                    break;
                  default:
                    return SizedBox(height: 18);
                }
              },
            ),
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
