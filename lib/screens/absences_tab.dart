import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';

List<Absence> allParsedAbsences = [];
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
  List<Absence> tempAbsences = [];
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
            if (n.id == globals.payloadId) {
              tempAbsence = n;
              break;
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
    //DataHandling
    tempAbsences = List.from(allParsedAbsences);
    listener = () async {
      setState(() {
        legendSelection = legendSelection;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        tempAbsences = List.from(allParsedAbsences);
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
      body: ListView(
        shrinkWrap: true,
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tempAbsences.length + globals.adModifier,
            itemBuilder: (context, index) {
              if (index >= tempAbsences.length) {
                return SizedBox(
                  height: 100,
                );
              }
              double opacity = 1;
              Color color = getAbsenceCardColor(tempAbsences[index]);
              var animationController;
              if (tempAbsences[index].justificationState == "BeJustified") {
                opacity = legendSelection.igazolando ? 1 : 0;
                animationController = _animationControllerBeJustified;
              } else if (tempAbsences[index].justificationState ==
                  "UnJustified") {
                opacity = legendSelection.igazolatlan ? 1 : 0;
                animationController = _animationControllerUnJustified;
              } else if (tempAbsences[index].justificationState ==
                  "Justified") {
                opacity = legendSelection.igazolt ? 1 : 0;
                animationController = _animationControllerJustified;
              }
              DateTime tempDate =
                  DateTime.parse(tempAbsences[index].lessonStartTimeString);
              String subTitle = tempAbsences[index].type == "Delay"
                  ? "${getTranslatedString("delay")}: ${tempAbsences[index].delayTimeMinutes} ${getTranslatedString("minutes")}"
                  : "${getTranslatedString("absence")}: ${tempDate.year}-${tempDate.month}-${tempDate.day} (${intToTHEnding(tempAbsences[index].numberOfLessons)} ${getTranslatedString("lesson")})";
              return AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: opacity,
                child: FadeTransition(
                  opacity: animationController
                      .drive(CurveTween(curve: Curves.linear)),
                  child: AnimatedTitleSubtitleCard(
                    heroAnimation: AlwaysStoppedAnimation(0),
                    color: color,
                    title: tempAbsences[index].teacher +
                        " - " +
                        capitalize(tempAbsences[index].subject),
                    subTitle: subTitle,
                    onPressed: AbsencencesDetailTab(
                      absence: tempAbsences[index],
                      color: color,
                    ),
                  ),
                ),
              );
            },
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
        bottom: false,
        left: false,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedMarksCard(
              eval: null,
              iconData: parseSubjectToIcon(subject: absence.subject),
              subTitle: "",
              title: absence.teacher + " - " + capitalize(absence.subject),
              color: color == null ? Colors.purple : color,
              onPressed: null,
            ),
            Divider(
              height: 0,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 6 + globals.adModifier,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 16, bottom: 16),
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
                    case 2:
                      return SizedBox(
                        child: Text(
                            "${getTranslatedString("teacher")}: " +
                                absence.teacher,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                      break;
                    case 3:
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
                    case 4:
                      return SizedBox(
                        child: Text(
                            "${getTranslatedString("stateOfJustification")}: " +
                                "${getTranslatedString(absence.justificationState)}",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                      break;
                    case 5:
                      return absence.justificationType != null ||
                              absence.justificationType != ""
                          ? SizedBox(
                              child: Text(
                                  "${getTranslatedString("justificationType")}: " +
                                      "${getTranslatedString(absence.justificationTypeName)}",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            )
                          : SizedBox(
                              width: 0,
                              height: 0,
                            );
                      break;
                    default:
                      return SizedBox(height: 100);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
