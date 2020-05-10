import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/dom.dart' as dom;
import 'package:novynaplo/global.dart' as globals;

Timer timer;

class HomeworkDetailTab extends StatefulWidget {
  const HomeworkDetailTab({
    this.hwInfo,
    this.color,
  });

  final Homework hwInfo;
  final Color color;

  @override
  _HomeworkDetailTabState createState() => _HomeworkDetailTabState();
}

class _HomeworkDetailTabState extends State<HomeworkDetailTab> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(),
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
        bottom: false,
        left: false,
        right: false,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(
            height: 60,
            child: DecoratedBox(
                decoration: BoxDecoration(color: widget.color),
                child: Center(
                  child: Text(
                    widget.hwInfo.subject,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                  ),
                )),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Házifeladat: ",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Html(
                                data: widget.hwInfo.content,
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
                            ]);
                        break;
                      case 1:
                        String due = widget.hwInfo.dueDate.year.toString() +
                            "-" +
                            widget.hwInfo.dueDate.month.toString() +
                            "-" +
                            widget.hwInfo.dueDate.day.toString() +
                            " " +
                            widget.hwInfo.dueDate.hour.toString() +
                            ":" +
                            widget.hwInfo.dueDate.minute.toString();
                        Duration left =
                            widget.hwInfo.dueDate.difference(DateTime.now());
                        String leftHours =
                            (left.inMinutes / 60).toStringAsFixed(0);
                        String leftMins =
                            (left.inMinutes % 60).toStringAsFixed(0);
                        String leftString =
                            "$leftHours órád és $leftMins perced";
                        bool dueOver = false;
                        if (left.inMinutes / 60 < 0) {
                          dueOver = true;
                        }
                        timer = new Timer.periodic(new Duration(minutes: 1),
                            (time) {
                          if (!mounted) {
                            timer.cancel();
                          } else {
                            setState(() {
                              left = widget.hwInfo.dueDate
                                  .difference(DateTime.now());
                              leftHours =
                                  (left.inMinutes / 60).toStringAsFixed(0);
                              leftMins =
                                  (left.inMinutes % 60).toStringAsFixed(0);
                              leftString =
                                  "$leftHours órád és $leftMins perced";
                              if (left.inMinutes / 60 < 0) {
                                dueOver = true;
                              } else {
                                dueOver = false;
                              }
                            });
                          }
                        });
                        if (dueOver) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Text(
                                "Házifeladat határideje: ",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(due + " (határidőn túl)",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red)),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Text(
                                "Házifeladat határideje: ",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text("$due (van még: $leftString)",
                                  style: TextStyle(
                                    fontSize: 20,
                                  )),
                            ],
                          );
                        }
                        break;
                      case 2:
                        String giveUp = widget.hwInfo.givenUp.year.toString() +
                            "-" +
                            widget.hwInfo.givenUp.month.toString() +
                            "-" +
                            widget.hwInfo.givenUp.day.toString() +
                            " " +
                            widget.hwInfo.givenUp.hour.toString() +
                            ":" +
                            widget.hwInfo.givenUp.minute.toString();
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "Házifeladat feladva: ",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                            Text(giveUp,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ],
                        );
                        break;
                      case 3:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "Házifeladatot feladta:",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 25.0, fontWeight: FontWeight.bold),
                            ),
                            Text(widget.hwInfo.teacher,
                                style: TextStyle(
                                  fontSize: 20,
                                )),
                          ],
                        );
                        break;
                      default:
                        return SizedBox(
                          height: 50,
                        );
                    }
                  }))
          //Expanded()
        ]));
  }
}
