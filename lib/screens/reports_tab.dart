import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marks;

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
    _tabController = new TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      drawer: getDrawer(ReportsTab.tag, context),
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
            /*return ListView.builder(
              itemCount: globals.markCount,
              padding: EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (BuildContext context, int index) {},);*/
            if (tab.text == getTranslatedString("FirstQuarter")) {
              List<Evals> firstQuarterEvaluationList =
                  marks.allParsedByDate.where(
                (item) {
                  return item.type == "IQuarterEvaluation" ? true : false;
                },
              ).toList();
              firstQuarterEvaluationList
                  .sort((a, b) => a.subject.compareTo(b.subject));
              return ListView.builder(
                itemCount: firstQuarterEvaluationList.length,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(firstQuarterEvaluationList[index].subject),
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
                                  "dicséret"
                              ? "Dicséretes\n"
                              : "") +
                          firstQuarterEvaluationList[index].value,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: Colors.red,
                    onPressed: null,
                  );
                },
              );
            } else if (tab.text == getTranslatedString("HalfYear")) {
              List<Evals> halfYearEvalList = marks.allParsedByDate.where(
                (item) {
                  return item.type == "HalfYear" ? true : false;
                },
              ).toList();
              halfYearEvalList.sort((a, b) => a.subject.compareTo(b.subject));
              return ListView.builder(
                itemCount: halfYearEvalList.length,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(halfYearEvalList[index].subject),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Text(
                      (halfYearEvalList[index].theme.toLowerCase() == "dicséret"
                              ? "Dicséretes\n"
                              : "") +
                          halfYearEvalList[index].value,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: Colors.red,
                    onPressed: null,
                  );
                },
              );
            } else if (tab.text == getTranslatedString("ThirdQuarter")) {
              //!Nem tudom
              return Text(marks.allParsedByDate
                  .where((item) {
                    return item.type == "HalfYear" ? true : false;
                  })
                  .length
                  .toString());
            } else if (tab.text == getTranslatedString("EndOfYear")) {
              List<Evals> endOfYearEvalList = marks.allParsedByDate.where(
                (item) {
                  return item.type == "EndYear" ? true : false;
                },
              ).toList();
              endOfYearEvalList.sort((a, b) => a.subject.compareTo(b.subject));
              return ListView.builder(
                itemCount: endOfYearEvalList.length,
                padding: EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (BuildContext context, int index) {
                  return AnimatedLeadingTrailingCard(
                    leading: Text(
                      capitalize(endOfYearEvalList[index].subject),
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
                                  "dicséret"
                              ? "Dicséretes\n"
                              : "") +
                          endOfYearEvalList[index].value,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    color: Colors.red,
                    onPressed: null,
                  );
                },
              );
            }
          }).toList()),
    );
  }
}
