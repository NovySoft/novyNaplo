import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/charts/absencesCharts.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
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
  List<List<Absence>> tempAbsences = [];
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
    Future.delayed(Duration(milliseconds: 600), () {
      _animationControllerJustified.forward();
      _animationControllerUnJustified.forward();
      _animationControllerBeJustified.forward();
    });
    //DataHandling on first open
    tempAbsences = List.from(allParsedAbsences);
    List<Absence> oneDAbsences =
        List.from(tempAbsences).expand((i) => i).toList().cast<Absence>();
    if (!legendSelection.igazolando) {
      oneDAbsences
          .removeWhere((element) => element.justificationState == "Igazolando");
    }
    if (!legendSelection.igazolatlan) {
      oneDAbsences.removeWhere(
          (element) => element.justificationState == "Igazolatlan");
    }
    if (!legendSelection.igazolt) {
      oneDAbsences
          .removeWhere((element) => element.justificationState == "Igazolt");
    }
    if (oneDAbsences.length != 0) {
      oneDAbsences.sort(
        (a, b) => (b.lesson.startDate.toHumanString() +
                " " +
                b.lesson.lessonNumber.toString())
            .compareTo(
          a.lesson.startDate.toHumanString() +
              " " +
              a.lesson.lessonNumber.toString(),
        ),
      );
      List<Absence> tempList = List.from(oneDAbsences);
      List<List<Absence>> outputList = [[]];
      int index = 0;
      DateTime dateBefore = tempList[0].lesson.startDate;
      for (var n in tempList) {
        if (!(n.lesson.startDate.isSameDay(dateBefore))) {
          index++;
          outputList.add([]);
          dateBefore = n.lesson.startDate;
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
        List<Absence> oneDAbsences = List.from(allParsedAbsences)
            .expand((i) => i)
            .toList()
            .cast<Absence>();

        _animationControllerJustified.reset();
        _animationControllerJustified.forward();

        _animationControllerBeJustified.reset();
        _animationControllerBeJustified.forward();

        _animationControllerUnJustified.reset();
        _animationControllerUnJustified.forward();

        if (!legendSelection.igazolando) {
          oneDAbsences.removeWhere(
              (element) => element.justificationState == "Igazolando");
        }
        if (!legendSelection.igazolatlan) {
          oneDAbsences.removeWhere(
              (element) => element.justificationState == "Igazolatlan");
        }
        if (!legendSelection.igazolt) {
          oneDAbsences.removeWhere(
              (element) => element.justificationState == "Igazolt");
        }
        if (oneDAbsences.length != 0) {
          oneDAbsences.sort(
            (a, b) => (b.lesson.startDate.toHumanString() +
                    " " +
                    b.lesson.lessonNumber.toString())
                .compareTo(
              a.lesson.startDate.toHumanString() +
                  " " +
                  a.lesson.lessonNumber.toString(),
            ),
          );
          List<Absence> tempList = List.from(oneDAbsences).cast<Absence>();
          List<List<Absence>> outputList = [[]];
          int index = 0;
          DateTime dateBefore = tempList[0].lesson.startDate;
          for (var n in tempList) {
            if (!isSameDay(n.lesson.startDate, dateBefore)) {
              index++;
              outputList.add([]);
              dateBefore = n.lesson.startDate;
            }
            outputList[index].add(n);
          }
          tempAbsences = outputList;
        } else {
          tempAbsences = [];
        }
        setState(() {
          tempAbsences = tempAbsences;
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
                      DateTime tempDate =
                          tempAbsences[listIndex][0].lesson.startDate;
                      String simplifiedDate = tempDate.toDayOnlyString();
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
                          "Igazolando") {
                        opacity = legendSelection.igazolando ? 1 : 0;
                        animationController = _animationControllerBeJustified;
                      } else if (tempAbsences[listIndex][index - 1]
                              .justificationState ==
                          "Igazolatlan") {
                        opacity = legendSelection.igazolatlan ? 1 : 0;
                        animationController = _animationControllerUnJustified;
                      } else if (tempAbsences[listIndex][index - 1]
                              .justificationState ==
                          "Igazolt") {
                        opacity = legendSelection.igazolt ? 1 : 0;
                        animationController = _animationControllerJustified;
                      }
                      DateTime tempDate =
                          tempAbsences[listIndex][index - 1].lesson.startDate;
                      String subTitle = tempAbsences[listIndex][index - 1]
                                  .delayInMinutes !=
                              null
                          ? "${getTranslatedString("delay")}: ${tempAbsences[listIndex][index - 1].delayInMinutes} ${getTranslatedString("minutes")}"
                          : "${getTranslatedString("absence")}: ${tempDate.toDayOnlyString()} (${intToTHEnding(tempAbsences[listIndex][index - 1].lesson.lessonNumber)} ${getTranslatedString("lesson")})";
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
                                capitalize(tempAbsences[listIndex][index - 1]
                                    .subject
                                    .name),
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
    return Scaffold(
      appBar: AppBar(title: Text(capitalize(absence.subject.name))),
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
                  parseSubjectToIcon(subject: absence.subject.name),
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
                        '${absence.delayInMinutes != null ? getTranslatedString("delayInfo") : getTranslatedString("absenceInfo")}:',
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
                              absence.subject.name,
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
                    DateTime tempDate = absence.lesson.startDate;
                    return SizedBox(
                      child: Text(
                          "${getTranslatedString("date")}: " +
                              "${tempDate.toDayOnlyString()} (${intToTHEnding(absence.lesson.lessonNumber)} ${getTranslatedString("lesson")})",
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
                    return absence.justificationType != null
                        ? SizedBox(
                            child: Text(
                                "${getTranslatedString("justificationType")}: " +
                                    "${getTranslatedString(absence.justificationType.name)}",
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
