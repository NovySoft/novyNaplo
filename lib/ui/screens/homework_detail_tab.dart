import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;

Timer timer;
List<Widget> downloadIcon = [];

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
  @override
  void initState() {
    for (int i = 0; i < widget.hwInfo.csatolmanyok.length; i++) {
      downloadIcon.add(Icon(MdiIcons.fileDownload));
    }
    FirebaseCrashlytics.instance.log("Shown Homework_detail_tab");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(),
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 60,
            child: DecoratedBox(
              decoration: BoxDecoration(color: widget.color),
              child: Center(
                child: Text(
                  widget.hwInfo.tantargy.nev,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${capitalize(getTranslatedString("hw"))}: ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          Html(
                            data: widget.hwInfo.szoveg,
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
                        ]);
                    break;
                  case 1:
                    String due = widget.hwInfo.hataridoDatuma.year.toString() +
                        "-" +
                        widget.hwInfo.hataridoDatuma.month.toString() +
                        "-" +
                        widget.hwInfo.hataridoDatuma.day.toString() +
                        " " +
                        widget.hwInfo.hataridoDatuma.hour.toString() +
                        ":" +
                        widget.hwInfo.hataridoDatuma.minute.toString();
                    Duration left =
                        widget.hwInfo.hataridoDatuma.difference(DateTime.now());
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
                          left = widget.hwInfo.hataridoDatuma
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
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          Text(
                            "${getTranslatedString("hDue")}: ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          Text(due + " (${getTranslatedString("overDue")})",
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
                            "${getTranslatedString("hDue")}: ",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              "$due (${getTranslatedString("hLeft")}: $leftString)",
                              style: TextStyle(
                                fontSize: 20,
                              )),
                        ],
                      );
                    }
                    break;
                  case 2:
                    if (widget.hwInfo.csatolmanyok.length == 0) {
                      return SizedBox(height: 0, width: 0);
                    }

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("attachments")}:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: widget.hwInfo.csatolmanyok.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Row(
                              children: [
                                downloadIcon[index],
                                SizedBox(width: 5, height: 5),
                                GestureDetector(
                                  onTap: () {
                                    print(
                                      widget.hwInfo.csatolmanyok[index].uid,
                                    );
                                    setState(() {
                                      downloadIcon[index] =
                                          Icon(MdiIcons.check);
                                      downloadIcon = downloadIcon;
                                    });
                                  },
                                  child: Text(
                                    widget.hwInfo.csatolmanyok[index].nev,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5, height: 30),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                    break;
                  case 3:
                    String giveUp =
                        widget.hwInfo.rogzitesIdopontja.year.toString() +
                            "-" +
                            widget.hwInfo.rogzitesIdopontja.month.toString() +
                            "-" +
                            widget.hwInfo.rogzitesIdopontja.day.toString() +
                            " " +
                            widget.hwInfo.rogzitesIdopontja.hour.toString() +
                            ":" +
                            widget.hwInfo.rogzitesIdopontja.minute.toString();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("dateGiveUp")}: ",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          giveUp,
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    );
                    break;
                  case 4:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("givenUpBy")}:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        Text(widget.hwInfo.tanar,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
