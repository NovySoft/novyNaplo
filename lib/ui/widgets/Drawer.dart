import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/calculator_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/reports_tab.dart';
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';
import 'package:novynaplo/config.dart' as config;

//TODO Add option to remove items from drawer or reorder cards
class GlobalDrawer {
  static Widget getDrawer(String screen, BuildContext context) {
    return Drawer(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            stretch: true,
            title: new Container(),
            leading: new Container(),
            backgroundColor: Colors.grey,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(config.menuLogo, fit: BoxFit.contain),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                switch (index) {
                  case 0:
                    return SizedBox(
                      height: 5,
                    );
                    break;
                  case 1:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("marks"))),
                      leading: Icon(Icons.create),
                      onTap: () {
                        if (screen == MarksTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, MarksTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 2:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("reports"))),
                      leading: Icon(MdiIcons.fileChart),
                      onTap: () {
                        if (screen == ReportsTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, ReportsTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 3:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("timetable"))),
                      leading: Icon(Icons.today),
                      onTap: () {
                        if (screen == TimetableTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, TimetableTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 4:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("exams"))),
                      leading: Icon(MdiIcons.clipboardText),
                      onTap: () {
                        if (screen == ExamsTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, ExamsTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 5:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("hw"))),
                      leading: Icon(MdiIcons.bagPersonalOutline),
                      onTap: () {
                        if (screen == HomeworkTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, HomeworkTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 6:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("notices"))),
                      leading: Icon(Icons.layers),
                      onTap: () {
                        if (screen == NoticesTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, NoticesTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 7:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("events"))),
                      leading: Icon(MdiIcons.pin),
                      onTap: () {
                        if (screen == EventsTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, EventsTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 8:
                    return ListTile(
                      title:
                          Text(capitalize(getTranslatedString("statistics"))),
                      leading: Icon(MdiIcons.chartScatterPlotHexbin),
                      onTap: () {
                        if (screen == StatisticsTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, StatisticsTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 9:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("markCalc"))),
                      leading: new Icon(MdiIcons.calculator),
                      onTap: () {
                        if (screen == CalculatorTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, CalculatorTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  case 10:
                    return ListTile(
                      title: Text(capitalize(getTranslatedString("settings"))),
                      leading: Icon(Icons.settings_applications),
                      onTap: () {
                        if (screen == SettingsTab.tag) {
                          Navigator.pop(context);
                        } else {
                          try {
                            Navigator.pushNamed(context, SettingsTab.tag);
                          } catch (e, s) {
                            FirebaseCrashlytics.instance.recordError(
                              e,
                              s,
                              reason: 'getDrawer',
                              printDetails: true,
                            );
                            print(e.message);
                          }
                        }
                      },
                    );
                    break;
                  default:
                    return SizedBox(
                      height: 200,
                    );
                }
              },
              childCount: 12,
            ),
          ),
        ],
      ),
    );
  }
}
