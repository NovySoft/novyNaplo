import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/intToTHEnding.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedTitleSubtitleCard.dart';

List<List<Absence>> allParsedAbsences = [];
List<charts.Series> seriesList;
AbsencesBarChartLegendSelection legendSelection =
    new AbsencesBarChartLegendSelection();
AbsencesBarChartLegendSelection legendSelectionBefore =
    new AbsencesBarChartLegendSelection();
var listener;

class AbsencesTab extends StatefulWidget {
  @override
  _AbsencesTabState createState() => _AbsencesTabState();
}

class _AbsencesTabState extends State<AbsencesTab>
    with TickerProviderStateMixin {
  List<dynamic> tempAbsences = [];
  AnimationController _animationControllerJustified;
  AnimationController _animationControllerUnJustified;
  AnimationController _animationControllerBeJustified;

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Absences");
    _animationControllerJustified = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animationControllerUnJustified = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animationControllerBeJustified = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    if (globals.payloadId != -1) {
      if (globals.notifPayload == "absence") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Absence tempAbsence;
          for (var n in allParsedAbsences) {
            for (var j in n) {
              if (j.id == globals.payloadId) {
                tempAbsence = j;
                break;
              }
            }
          }
          if (tempAbsence != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AbsencencesDetailTab(
                  absence: tempAbsence,
                  color: getAbsenceCardColor(tempAbsence),
                ),
              ),
            );
          }
          globals.payloadId = -1;
        });
      }
    }
    Future.delayed(Duration(milliseconds: 600), () {
      _animationControllerJustified.forward();
      _animationControllerUnJustified.forward();
      _animationControllerBeJustified.forward();
    });
    //DataHandling on first open
    tempAbsences = List.from(allParsedAbsences);
    tempAbsences = List.from(allParsedAbsences).expand((i) => i).toList();
    if (!legendSelection.igazolando) {
      tempAbsences.removeWhere(
          (element) => element.justificationState == "BeJustified");
    }
    if (!legendSelection.igazolatlan) {
      tempAbsences.removeWhere(
          (element) => element.justificationState == "UnJustified");
    }
    if (!legendSelection.igazolt) {
      tempAbsences
          .removeWhere((element) => element.justificationState == "Justified");
    }
    if (tempAbsences.length != 0) {
      tempAbsences.sort(
        (a, b) => (b.lessonStartTimeString + " " + b.numberOfLessons.toString())
            .compareTo(
          a.lessonStartTimeString + " " + a.numberOfLessons.toString(),
        ),
      );
      List<dynamic> tempList = List.from(tempAbsences);
      List<List<Absence>> outputList = [[]];
      int index = 0;
      DateTime dateBefore = DateTime.parse(tempList[0].lessonStartTimeString);
      for (var n in tempList) {
        if (!DateTime.parse(n.lessonStartTimeString).isSameDay(dateBefore)) {
          index++;
          outputList.add([]);
          dateBefore = DateTime.parse(n.lessonStartTimeString);
        }
        outputList[index].add(n);
      }
      tempAbsences = outputList;
    } else {
      tempAbsences = [];
    }
    //Listener to handle chart changes
    listener = () async {
      setState(() {
        legendSelection = legendSelection;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        tempAbsences = List.from(allParsedAbsences).expand((i) => i).toList();
        //TODO: Fix fade in
        _animationControllerJustified.reset();
        _animationControllerJustified.forward();

        _animationControllerBeJustified.reset();
        _animationControllerBeJustified.forward();

        _animationControllerUnJustified.reset();
        _animationControllerUnJustified.forward();

        if (!legendSelection.igazolando) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "BeJustified");
        }
        if (!legendSelection.igazolatlan) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "UnJustified");
        }
        if (!legendSelection.igazolt) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "Justified");
        }
        if (tempAbsences.length != 0) {
          tempAbsences.sort(
            (a, b) =>
                (b.lessonStartTimeString + " " + b.numberOfLessons.toString())
                    .compareTo(
              a.lessonStartTimeString + " " + a.numberOfLessons.toString(),
            ),
          );
          List<dynamic> tempList = List.from(tempAbsences);
          List<List<Absence>> outputList = [[]];
          int index = 0;
          DateTime dateBefore =
              DateTime.parse(tempList[0].lessonStartTimeString);
          for (var n in tempList) {
            if (!DateTime.parse(n.lessonStartTimeString)
                .isSameDay(dateBefore)) {
              index++;
              outputList.add([]);
              dateBefore = DateTime.parse(n.lessonStartTimeString);
            }
            outputList[index].add(n);
          }
          tempAbsences = outputList;
        } else {
          tempAbsences = [];
        }
        setState(() {
          legendSelection = legendSelection;
        });
        legendSelectionBefore = legendSelection;
      });
    };
    legendSelection.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    legendSelection.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext build) {
    // ignore: unused_local_variable
    int _index = 0;
    List<String> hiddenSeries = [];
    if (!legendSelection.igazolando) {
      hiddenSeries.add(getTranslatedString("BeJustified"));
    }
    if (!legendSelection.igazolatlan) {
      hiddenSeries.add(getTranslatedString("UnJustified"));
    }
    if (!legendSelection.igazolt) {
      hiddenSeries.add(getTranslatedString("Justified"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(getTranslatedString("absencesAndDelays"))),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: AbsencesBarChart(
              defaultHiddenSeries: hiddenSeries,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tempAbsences.length + globals.adModifier,
              itemBuilder: (context, listIndex) {
                if (listIndex >= tempAbsences.length) {
                  return SizedBox(
                    height: 100,
                  );
                }
                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: tempAbsences[listIndex].length +
                      (tempAbsences[listIndex].length == 0 ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      DateTime tempDate = DateTime.parse(
                          tempAbsences[listIndex][0].lessonStartTimeString);
                      String simplifiedDate =
                          "${tempDate.year}-${tempDate.month}-${tempDate.day}";
                      return Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          "$simplifiedDate:",
                          textAlign: defaultTargetPlatform == TargetPlatform.iOS
                              ? TextAlign.center
                              : TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 21,
                          ),
                        ),
                      );
                    } else {
                      double opacity = 1;
                      Color color = getAbsenceCardColor(
                          tempAbsences[listIndex][index - 1]);
                      var animationController;
                      if (tempAbsences[listIndex][index - 1]
                              .justificationState ==
                          "BeJustified") {
                        opacity = legendSelection.igazolando ? 1 : 0;
                        animationController = _animationControllerBeJustified;
                      } else if (tempAbsences[listIndex][index - 1]
                              .justificationState ==
                          "UnJustified") {
                        opacity = legendSelection.igazolatlan ? 1 : 0;
                        animationController = _animationControllerUnJustified;
                      } else if (tempAbsences[listIndex][index - 1]
                              .justificationState ==
                          "Justified") {
                        opacity = legendSelection.igazolt ? 1 : 0;
                        animationController = _animationControllerJustified;
                      }
                      DateTime tempDate = DateTime.parse(tempAbsences[listIndex]
                              [index - 1]
                          .lessonStartTimeString);
                      String subTitle = tempAbsences[listIndex][index - 1]
                                  .type ==
                              "Delay"
                          ? "${getTranslatedString("delay")}: ${tempAbsences[listIndex][index - 1].delayTimeMinutes} ${getTranslatedString("minutes")}"
                          : "${getTranslatedString("absence")}: ${tempDate.year}-${tempDate.month}-${tempDate.day} (${intToTHEnding(tempAbsences[listIndex][index - 1].numberOfLessons)} ${getTranslatedString("lesson")})";
                      return AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: opacity,
                        child: FadeTransition(
                          opacity: animationController
                              .drive(CurveTween(curve: Curves.linear)),
                          child: AnimatedTitleSubtitleCard(
                            heroAnimation: AlwaysStoppedAnimation(0),
                            color: color,
                            title: tempAbsences[listIndex][index - 1].teacher +
                                " - " +
                                capitalize(
                                    tempAbsences[listIndex][index - 1].subject),
                            subTitle: subTitle,
                            onPressed: AbsencencesDetailTab(
                              absence: tempAbsences[listIndex][index - 1],
                              color: color,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AbsencencesDetailTab extends StatelessWidget {
  AbsencencesDetailTab({@required this.absence, this.color});
  final Absence absence;
  final Color color;
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(title: Text(capitalize(absence.subject))),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              stretch: true,
              title: new Container(),
              leading: new Container(),
              backgroundColor: color == null ? Colors.purple : color,
              expandedHeight: 250.0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: [StretchMode.zoomBackground],
                background: Icon(
                  parseSubjectToIcon(subject: absence.subject),
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
                        '${absence.type == "Delay" ? getTranslatedString("delayInfo") : getTranslatedString("absenceInfo")}:',
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
                          "${getTranslatedString("subject")}: " +
                              absence.subject,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 3:
                    return SizedBox(
                      child: Text(
                          "${getTranslatedString("teacher")}: " +
                              absence.teacher,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 5:
                    DateTime tempDate =
                        DateTime.parse(absence.lessonStartTimeString);
                    return SizedBox(
                      child: Text(
                          "${getTranslatedString("date")}: " +
                              "${tempDate.year}-${tempDate.month}-${tempDate.day} (${intToTHEnding(absence.numberOfLessons)} ${getTranslatedString("lesson")})",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 7:
                    return SizedBox(
                      child: Text(
                          "${getTranslatedString("stateOfJustification")}: " +
                              "${getTranslatedString(absence.justificationState)}",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 9:
                    return absence.justificationType != null ||
                            absence.justificationType != ""
                        ? SizedBox(
                            child: Text(
                                "${getTranslatedString("justificationType")}: " +
                                    "${getTranslatedString(absence.justificationTypeName)}",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          )
                        : SizedBox(
                            width: 0,
                            height: 0,
                          );
                    break;
                  case 10:
                    return SizedBox(
                      height: 250,
                    );
                    break;
                  default:
                    return SizedBox(height: 10);
                }
              }, childCount: 11),
            ),
          ],
        ),
      ),
    );
  }
}
