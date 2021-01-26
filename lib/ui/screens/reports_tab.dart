import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/charts/createSubjectChart.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/reports_detail_tab.dart';
import 'package:novynaplo/ui/widgets/AnimatedLeadingTrailingCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marks;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:novynaplo/global.dart' as globals;

Map<String, List<Evals>> reportMaps = {
  "FirstQuarter": [],
  "HalfYear": [],
  "ThirdQuarter": [],
  "EndOfYear": [],
};

class ReportsTab extends StatefulWidget {
  static String tag = 'reports';
  static String title = capitalize(getTranslatedString("reports"));

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Tab> tabs = [];

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Reports");
    //*"TypeName": "I_ne_jegy_ertekeles",
    reportMaps["FirstQuarter"] = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "I_ne_jegy_ertekeles";
      },
    ).toList();
    //*"TypeName": "felevi_jegy_ertekeles" || "II_ne_jegy_ertekeles",
    reportMaps["HalfYear"] = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "felevi_jegy_ertekeles" ||
            item.type.name == "II_ne_jegy_ertekeles";
      },
    ).toList();
    //*"TypeName": "III_ne_jegy_ertekeles"
    reportMaps["ThirdQuarter"] = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "III_ne_jegy_ertekeles";
      },
    ).toList();
    //*"TypeName": "evvegi_jegy_ertekeles" || "IV_ne_jegy_ertekeles"
    reportMaps["EndOfYear"] = marks.allParsedByDate.where(
      (item) {
        return item.type.name == "evvegi_jegy_ertekeles" ||
            item.type.name == "IV_ne_jegy_ertekeles";
      },
    ).toList();
    //*Sort the lists based on kretas sortIndex
    reportMaps["FirstQuarter"].sort(
      (a, b) => a.sortIndex.compareTo(b.sortIndex),
    );
    reportMaps["HalfYear"].sort(
      (a, b) => a.sortIndex.compareTo(b.sortIndex),
    );
    reportMaps["ThirdQuarter"].sort(
      (a, b) => a.sortIndex.compareTo(b.sortIndex),
    );
    reportMaps["EndOfYear"].sort(
      (a, b) => a.sortIndex.compareTo(b.sortIndex),
    );
    //*Only show existing reports
    if (reportMaps["FirstQuarter"].length != 0) {
      tabs.add(
        Tab(
          text: getTranslatedString("FirstQuarter"),
          icon: Icon(MdiIcons.clockTimeThree),
        ),
      );
    }
    if (reportMaps["HalfYear"].length != 0) {
      tabs.add(
        Tab(
          text: getTranslatedString("HalfYear"),
          icon: Icon(MdiIcons.clockTimeSix),
        ),
      );
    }
    if (reportMaps["ThirdQuarter"].length != 0) {
      tabs.add(
        Tab(
          text: getTranslatedString("ThirdQuarter"),
          icon: Icon(MdiIcons.clockTimeNine),
        ),
      );
    }
    if (reportMaps["EndOfYear"].length != 0) {
      tabs.add(
        Tab(
          text: getTranslatedString("EndOfYear"),
          icon: Icon(MdiIcons.clockTimeTwelve),
        ),
      );
    }
    if (tabs.length == 0) {
      tabs.add(
        Tab(
          text: capitalize(getTranslatedString("nothing")),
          icon: Icon(MdiIcons.emoticonSadOutline),
        ),
      );
    }
    _tabController = new TabController(vsync: this, length: tabs.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO Add a contracted card to reports
    return Scaffold(
      drawer: GlobalDrawer.getDrawer(ReportsTab.tag, context),
      appBar: AppBar(
        title: Text(ReportsTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((Tab tab) {
          if (tab.text == capitalize(getTranslatedString("nothing"))) {
            return noReports();
          } else {
            String tabName;
            if (tab.text == getTranslatedString("FirstQuarter")) {
              tabName = "FirstQuarter";
            } else if (tab.text == getTranslatedString("HalfYear")) {
              tabName = "HalfYear";
            } else if (tab.text == getTranslatedString("ThirdQuarter")) {
              tabName = "ThirdQuarter";
            } else if (tab.text == getTranslatedString("EndOfYear")) {
              tabName = "EndOfYear";
            }
            return ListView.builder(
              itemCount: reportMaps[tabName].length + globals.adModifier,
              padding: EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (BuildContext context, int index) {
                if (reportMaps[tabName].length <= index) {
                  return SizedBox(
                    height: 100,
                  );
                }
                Color color = getMarkCardColor(
                  eval: reportMaps[tabName][index],
                  index: index,
                );
                int statListIndex = stats.allParsedSubjects.indexWhere(
                    (element) =>
                        element[0].subject.name.toLowerCase() ==
                        reportMaps[tabName][index].subject.name.toLowerCase());
                List<dynamic> chartListPoints =
                    stats.allParsedSubjects[statListIndex].where((element) {
                  if (element.date.compareTo(reportMaps[tabName][index].date) <=
                      0) {
                    return true;
                  } else {
                    return false;
                  }
                }).toList();
                return AnimatedLeadingTrailingCard(
                  leading: Text(
                    capitalize(reportMaps[tabName][index].subject.name),
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Text(
                    (reportMaps[tabName][index].theme.toLowerCase() ==
                                    "dicséret" ||
                                reportMaps[tabName][index]
                                        .theme
                                        .toLowerCase() ==
                                    "kitűnő"
                            ? "${getTranslatedString("praiseworthy")}\n"
                            : "") +
                        reportMaps[tabName][index].textValue,
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
                        "${getTranslatedString(tabName).toLowerCase()} ${reportMaps[tabName][index].subject.name}",
                    eval: reportMaps[tabName][index],
                    color: color,
                    chartList: statListIndex != -1
                        ? createSubjectChart(chartListPoints, index.toString())
                        : null,
                  ),
                );
              },
            );
          }
        }).toList(),
      ),
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
