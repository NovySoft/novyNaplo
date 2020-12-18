import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/charts/createSubjectChart.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/ui/screens/reports_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/ui/widgets/AnimatedLeadingTrailingCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';

List<Evals> firstQuarterEvaluationList;
List<Evals> halfYearEvalList;
List<Evals> thirdQuarterEvalList;
List<Evals> endOfYearEvalList;

TabController _tabController;
final List<Tab> reportTabs = <Tab>[
  //*"Type": "IQuarterEvaluation",
  Tab(
    text: getTranslatedString("FirstQuarter"),
    icon: Icon(MdiIcons.clockTimeThree),
  ),
  //*"Type": "HalfYear",
  Tab(
    text: getTranslatedString("HalfYear"),
    icon: Icon(MdiIcons.clockTimeSix),
  ),
  //TODO megkeresni
  //!Nem tudom
  Tab(
    text: getTranslatedString("ThirdQuarter"),
    icon: Icon(MdiIcons.clockTimeNine),
  ),
  //*"Type": "EndYear"
  Tab(
    text: getTranslatedString("EndOfYear"),
    icon: Icon(MdiIcons.clockTimeTwelve),
  ),
];

class ReportsTab extends StatefulWidget {
  static String tag = 'reports';
  static String title = capitalize(getTranslatedString("reports"));

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Reports");
    _tabController = new TabController(vsync: this, length: 4);
    //LoadData
    //*FirstQuarter
    firstQuarterEvaluationList = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "I_ne_jegy_ertekeles" ? true : false;
      },
    ).toList();
    firstQuarterEvaluationList
        .sort((a, b) => a.subject.name.compareTo(b.subject.name));
    //*HalfYear
    halfYearEvalList = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "felevi_jegy_ertekeles" ? true : false;
      },
    ).toList();
    halfYearEvalList.sort((a, b) => a.subject.name.compareTo(b.subject.name));
    //*EndOfYear
    endOfYearEvalList = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "evvegi_jegy_ertekeles" ? true : false;
      },
    ).toList();
    endOfYearEvalList.sort((a, b) => a.subject.name.compareTo(b.subject.name));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO Add a contracted card to reports
    globals.globalContext = context;
    return Scaffold(
      drawer: GlobalDrawer.getDrawer(ReportsTab.tag, context),
      appBar: AppBar(
        title: Text(ReportsTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: reportTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: reportTabs.map((Tab tab) {
            if (tab.text == getTranslatedString("FirstQuarter")) {
              if (firstQuarterEvaluationList.length == 0) {
                return noReports();
              }
              return ListView.builder(
                itemCount: firstQuarterEvaluationList.length + 1,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  if (firstQuarterEvaluationList.length <= index) {
                    return SizedBox(
                      height: 60,
                    );
                  }
                  Color color = getMarkCardColor(
                    eval: firstQuarterEvaluationList[index],
                    index: index,
                  );
                  int statListIndex = stats.allParsedSubjects.indexWhere(
                      (element) =>
                          element[0].subject.name.toLowerCase() ==
                          firstQuarterEvaluationList[index]
                              .subject
                              .name
                              .toLowerCase());
                  List<dynamic> chartListPoints =
                      stats.allParsedSubjects[statListIndex].where((element) {
                    if (element.date.compareTo(
                            firstQuarterEvaluationList[index].date) <=
                        0) {
                      return true;
                    } else {
                      return false;
                    }
                  }).toList();
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(
                          firstQuarterEvaluationList[index].subject.name),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      (firstQuarterEvaluationList[index].theme.toLowerCase() ==
                                      "dicséret" ||
                                  firstQuarterEvaluationList[index]
                                          .theme
                                          .toLowerCase() ==
                                      "kitűnő"
                              ? "${getTranslatedString("praiseworthy")}\n"
                              : "") +
                          firstQuarterEvaluationList[index].textValue,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: color,
                    onPressed: ReportsDetailTab(
                      title:
                          "${getTranslatedString("FirstQuarter").toLowerCase()} ${firstQuarterEvaluationList[index].subject.name}",
                      eval: firstQuarterEvaluationList[index],
                      color: color,
                      chartList: statListIndex != -1
                          ? createSubjectChart(
                              chartListPoints, index.toString())
                          : null,
                    ),
                  );
                },
              );
            } else if (tab.text == getTranslatedString("HalfYear")) {
              if (halfYearEvalList.length == 0) {
                return noReports();
              }
              return ListView.builder(
                itemCount: halfYearEvalList.length + 1,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  if (halfYearEvalList.length <= index) {
                    return SizedBox(
                      height: 60,
                    );
                  }
                  Color color = getMarkCardColor(
                    eval: halfYearEvalList[index],
                    index: index,
                  );
                  int statListIndex = stats.allParsedSubjects.indexWhere(
                      (element) =>
                          element[0].subject.name.toLowerCase() ==
                          halfYearEvalList[index].subject.name.toLowerCase());
                  List<dynamic> chartListPoints =
                      stats.allParsedSubjects[statListIndex].where((element) {
                    if (element.date.compareTo(halfYearEvalList[index].date) <=
                        0) {
                      return true;
                    } else {
                      return false;
                    }
                  }).toList();
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(halfYearEvalList[index].subject.name),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      (halfYearEvalList[index].theme.toLowerCase() ==
                                      "dicséret" ||
                                  halfYearEvalList[index].theme.toLowerCase() ==
                                      "kitűnő"
                              ? "${getTranslatedString("praiseworthy")}\n"
                              : "") +
                          halfYearEvalList[index].textValue,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: color,
                    onPressed: ReportsDetailTab(
                      title:
                          "${getTranslatedString("HalfYear").toLowerCase()} ${halfYearEvalList[index].subject.name}",
                      eval: halfYearEvalList[index],
                      color: color,
                      chartList: statListIndex != -1
                          ? createSubjectChart(
                              chartListPoints, index.toString())
                          : null,
                    ),
                  );
                },
              );
            } else if (tab.text == getTranslatedString("ThirdQuarter")) {
              //!Nem tudom
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      MdiIcons.emoticonSadOutline,
                      size: 50,
                    ),
                    Text(
                      "Még nem elérhető\nNot yet available!",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              );
            } else if (tab.text == getTranslatedString("EndOfYear")) {
              if (endOfYearEvalList.length == 0) {
                return noReports();
              }
              return ListView.builder(
                itemCount: endOfYearEvalList.length + 1,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  if (endOfYearEvalList.length <= index) {
                    return SizedBox(
                      height: 60,
                    );
                  }
                  Color color = getMarkCardColor(
                    eval: endOfYearEvalList[index],
                    index: index,
                  );
                  int statListIndex = stats.allParsedSubjects.indexWhere(
                      (element) =>
                          element[0].subject.name.toLowerCase() ==
                          endOfYearEvalList[index].subject.name.toLowerCase());
                  List<dynamic> chartListPoints =
                      stats.allParsedSubjects[statListIndex].where((element) {
                    if (element.date.compareTo(endOfYearEvalList[index].date) <=
                        0) {
                      return true;
                    } else {
                      return false;
                    }
                  }).toList();
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(endOfYearEvalList[index].subject.name),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      (endOfYearEvalList[index].theme.toLowerCase() ==
                                      "dicséret" ||
                                  endOfYearEvalList[index]
                                          .theme
                                          .toLowerCase() ==
                                      "kitűnő"
                              ? "${getTranslatedString("praiseworthy")}\n"
                              : "") +
                          endOfYearEvalList[index].textValue,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: color,
                    onPressed: ReportsDetailTab(
                      title:
                          "${getTranslatedString("EndOfYear").toLowerCase()} ${endOfYearEvalList[index].subject.name}",
                      eval: endOfYearEvalList[index],
                      color: color,
                      chartList: statListIndex != -1
                          ? createSubjectChart(
                              chartListPoints, index.toString())
                          : null,
                    ),
                  );
                },
              );
            } else {
              return SizedBox(
                height: 50,
              );
            }
          }).toList()),
    );
  }
}

Widget noReports() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          MdiIcons.emoticonSadOutline,
          size: 50,
        ),
        Text(
          "${getTranslatedString("noReport")}!",
          textAlign: TextAlign.center,
        )
      ],
    ),
  );
}
