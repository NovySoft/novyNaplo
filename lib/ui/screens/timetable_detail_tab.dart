import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';

Timer timer;
List<Widget> downloadIcon = [];

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
    downloadIcon = [];
    if (widget.lessonInfo.homework != null) {
      for (int i = 0; i < widget.lessonInfo.homework.attachments.length; i++) {
        downloadIcon.add(Icon(MdiIcons.fileDownload));
      }
    }
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
                color: globals.timetableCardTheme == "Dark"
                    ? Colors.grey[350]
                    : Colors.black38,
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              Widget child = getTimetableContent(context, index);
              return Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: child,
                  ),
                ],
              );
            }, childCount: 25),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;
    title = widget.lessonInfo.state.name == "Elmaradt" ||
            widget.lessonInfo.type.name == "UresOra"
        ? getTranslatedString("cancelled") + " " + widget.lessonInfo.name
        : widget.lessonInfo.name;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor:
            globals.appBarTextColoredByUser ? globals.currentUser.color : null,
        title: Text(title),
      ),
      body: _buildBody(),
    );
  }

  Widget getTimetableContent(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(left: 15, top: 16, bottom: 16),
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
              "${getTranslatedString("nameOfLesson")}: ${widget.lessonInfo.name != null ? widget.lessonInfo.name : ""}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );
        break;
      case 3:
        return SizedBox(
          child: Text(
            "${getTranslatedString("themeOfLesson")}: ${widget.lessonInfo.theme != null ? widget.lessonInfo.theme : getTranslatedString("unknown")}",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        );
        break;
      case 5:
        return SizedBox(
          child: Text(
              "${getTranslatedString("subject")}: ${widget.lessonInfo.subject.name != null ? widget.lessonInfo.subject.name : ""}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );
        break;
      case 7:
        return SizedBox(
          child: Text(
              "${getTranslatedString("classroom")}: ${widget.lessonInfo.classroom != null ? widget.lessonInfo.classroom : ""}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );
        break;
      case 9:
        if (widget.lessonInfo.deputyTeacher != null) {
          return SizedBox(
            child: Row(
              children: [
                Text(
                  "${getTranslatedString("deputy")}: ",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  "${widget.lessonInfo.deputyTeacher}",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            child: Text(
                "${getTranslatedString("teacher")}: ${widget.lessonInfo.teacher != null ? widget.lessonInfo.teacher : ""}",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          );
        }
        break;
      case 11:
        if (widget.lessonInfo.date != null) {
          String date = widget.lessonInfo.date.toDayOnlyString();
          return SizedBox(
            child: Text("${getTranslatedString("date")}: $date",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          );
        } else {
          return SizedBox(height: 0, width: 0);
        }
        break;
      case 13:
        if (widget.lessonInfo.startDate == null ||
            widget.lessonInfo.endDate == null) {
          return SizedBox(height: 0, width: 0);
        }
        String startMinutes;
        if (widget.lessonInfo.startDate.minute.toString().startsWith("0")) {
          startMinutes = widget.lessonInfo.startDate.minute.toString() + "0";
        } else {
          startMinutes = widget.lessonInfo.startDate.minute.toString();
        }
        String endMinutes;
        if (widget.lessonInfo.endDate.minute.toString().startsWith("0")) {
          endMinutes = widget.lessonInfo.endDate.minute.toString() + "0";
        } else {
          endMinutes = widget.lessonInfo.endDate.minute.toString();
        }
        String start =
            widget.lessonInfo.startDate.hour.toString() + ":" + startMinutes;
        String end =
            widget.lessonInfo.endDate.hour.toString() + ":" + endMinutes;
        return SizedBox(
          child: Text("${getTranslatedString("startStop")}: $start - $end",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );
        break;
      case 15:
        if (widget.lessonInfo.startDate == null ||
            widget.lessonInfo.endDate == null) {
          return SizedBox(height: 0, width: 0);
        }
        Duration diff =
            widget.lessonInfo.endDate.difference(widget.lessonInfo.startDate);
        return SizedBox(
          child: Text(
              "${getTranslatedString("period")}: ${diff.inMinutes.toString()} ${getTranslatedString("minutes")}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );
        break;
      case 17:
        return widget.lessonInfo.group.name != null
            ? SizedBox(
                child: Text(
                    "${getTranslatedString("class")}: ${widget.lessonInfo.group.name}",
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              )
            : SizedBox(height: 0, width: 0);
        break;
      case 19:
        if (widget.lessonInfo.examList != null &&
            widget.lessonInfo.examList.length != 0) {
          return SizedBox(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 18),
                  Text(
                    "${capitalize(getTranslatedString("thisLessonsExams"))}: ",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          Html(
                            data:
                                "${widget.lessonInfo.examList[index].mode.description}: ${widget.lessonInfo.examList[index].theme}",
                            onLinkTap: (
                              String url,
                              RenderContext context,
                              Map<String, String> attributes,
                              var element,
                            ) async {
                              if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url));
                              } else {
                                FirebaseAnalytics.instance.logEvent(
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
                    itemCount: widget.lessonInfo.examList.length,
                  ),
                ],
              ),
            ),
          );
        } else {
          return SizedBox(
            height: 0,
            width: 0,
          );
        }
        break;
      case 20:
        if (widget.lessonInfo.teacherHwUid != null &&
            widget.lessonInfo.teacherHwUid != "") {
          String due = widget.lessonInfo.homework.dueDate.toHumanString();
          Duration left =
              widget.lessonInfo.homework.dueDate.difference(DateTime.now());
          String leftHours = (left.inMinutes / 60).toStringAsFixed(0);
          String leftMins = (left.inMinutes % 60).toStringAsFixed(0);
          String leftString =
              "$leftHours ${getTranslatedString("yHrs")} ${getTranslatedString("and")} $leftMins ${getTranslatedString("yMins")}";
          bool dueOver = false;
          if (left.inMinutes / 60 < 0) {
            dueOver = true;
          }
          timer = new Timer.periodic(new Duration(minutes: 1), (time) {
            if (!mounted) {
              timer.cancel();
            } else {
              setState(() {
                left = widget.lessonInfo.homework.dueDate
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
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Html(
                  data: widget.lessonInfo.homework.content,
                  onLinkTap: (
                    String url,
                    RenderContext context,
                    Map<String, String> attributes,
                    var element,
                  ) async {
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      FirebaseAnalytics.instance.logEvent(
                        name: "LinkFail",
                        parameters: {"link": url},
                      );
                      throw 'Could not launch $url';
                    }
                  },
                ),
                SizedBox(height: 5),
                widget.lessonInfo.homework == null
                    ? SizedBox(
                        height: 0,
                        width: 0,
                      )
                    : widget.lessonInfo.homework.attachments.length == 0
                        ? SizedBox(
                            height: 0,
                            width: 0,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "${getTranslatedString("attachments")}:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: widget
                                    .lessonInfo.homework.attachments.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        downloadIcon[index] = SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(),
                                        );
                                      });
                                      try {
                                        await RequestHandler
                                            .downloadHWAttachment(
                                          globals.currentUser,
                                          hwInfo: widget.lessonInfo.homework
                                              .attachments[index],
                                        );
                                        setState(() {
                                          downloadIcon[index] =
                                              Icon(MdiIcons.check);
                                        });
                                      } catch (e, s) {
                                        if (!(await NetworkHelper
                                            .isNetworkAvailable())) {
                                          ErrorToast.showErrorToast(
                                            getTranslatedString("noNet"),
                                          );
                                        } else {
                                          FirebaseCrashlytics.instance
                                              .recordError(
                                            e,
                                            s,
                                            reason: 'downloadHWAttachment',
                                            printDetails: true,
                                          );
                                          ErrorToast.showErrorToast(
                                            '${getTranslatedString("errWhileFetch")}: $e',
                                          );
                                        }
                                        setState(() {
                                          downloadIcon[index] =
                                              Icon(MdiIcons.exclamation);
                                        });
                                      }
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(width: 3, height: 5),
                                        downloadIcon[index],
                                        SizedBox(width: 5, height: 5),
                                        Text(
                                          widget.lessonInfo.homework
                                              .attachments[index].name,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 17,
                                          ),
                                        ),
                                        SizedBox(width: 5, height: 30),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
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
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
              ],
            ),
          ));
        } else {
          return SizedBox(
            height: 0,
            width: 0,
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
  }
}
