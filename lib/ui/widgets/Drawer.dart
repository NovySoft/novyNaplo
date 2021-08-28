import 'package:animations/animations.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/calculator/calculator_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/loading_screen.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/reports_tab.dart';
import 'package:novynaplo/ui/screens/settings/settings_tab.dart';
import 'package:novynaplo/ui/screens/settings/user/userManager_settings.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/global.dart' as globals;

String userDropdownValue = "";

class CustomDrawer extends StatefulWidget {
  const CustomDrawer(
    this.screen,
  );
  final String screen;

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<String> dropdownItems = [];
  bool isEdited = false;

  void updateUserList(bool outsideCall) {
    isEdited = outsideCall;
    List<Student> tempList = List.from(globals.allUsers);
    tempList.sort(
      (a, b) => a.institution.userPosition.compareTo(
        b.institution.userPosition,
      ),
    );
    dropdownItems = tempList.map((user) => user.nickname ?? user.name).toList();
    userDropdownValue =
        globals.currentUser.nickname ?? globals.currentUser.name;
    if (outsideCall) {
      setState(() {
        isEdited = isEdited;
        dropdownItems = dropdownItems;
        userDropdownValue = userDropdownValue;
      });
    }
  }

  @override
  void initState() {
    updateUserList(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: globals.darker ? 0 : 16,
      child: Container(
        color: globals.darker
            ? Colors.black
            : DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.white
                : Color.fromARGB(100, 48, 48, 48),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              stretch: true,
              title: new Container(),
              leading: new Container(),
              backgroundColor: globals.darker ? Color(0xFF212121) : Colors.grey,
              expandedHeight: 120.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.asset(
                  config.menuLogo,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  switch (index) {
                    case 0:
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: userDropdownValue,
                                  icon: const Icon(Icons.arrow_downward),
                                  underline: Container(
                                      height: 0, color: Colors.transparent),
                                  iconSize: 17,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  onChanged: (String newValue) async {
                                    if (newValue == "manageUsers" ||
                                        newValue == userDropdownValue) return;
                                    setState(() {
                                      userDropdownValue = newValue;
                                    });
                                    await DatabaseHelper.setCurrentUser(
                                      globals.allUsers
                                          .firstWhere(
                                            (element) =>
                                                element.nickname == newValue ||
                                                element.name == newValue,
                                          )
                                          .userId,
                                    );
                                    await Navigator.pushReplacementNamed(
                                      context,
                                      LoadingPage.tag,
                                    );
                                  },
                                  items: dropdownItems
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList() +
                                      [
                                        DropdownMenuItem<String>(
                                          value: "manageUsers",
                                          child: OpenContainer(
                                            onClosed: (_) {
                                              if (isEdited) {
                                                Navigator.of(context).pop();
                                                isEdited = false;
                                              }
                                            },
                                            closedColor:
                                                Theme.of(context).canvasColor,
                                            openColor:
                                                Theme.of(context).canvasColor,
                                            closedElevation: 0,
                                            openElevation: 0,
                                            transitionDuration: Duration(
                                              milliseconds: 450,
                                            ),
                                            closedBuilder: (
                                              BuildContext context,
                                              VoidCallback openContainer,
                                            ) =>
                                                Row(
                                              children: [
                                                Icon(Feather.users),
                                                SizedBox(width: 10),
                                                Text(
                                                  getTranslatedString(
                                                      "manageUsers"),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            openBuilder: (BuildContext context,
                                                    VoidCallback
                                                        openContainer) =>
                                                UserManager(
                                              setStateCallback: updateUserList,
                                            ),
                                          ),
                                        )
                                      ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: globals.darker
                                ? Color(0xFF212121)
                                : Colors.grey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      );
                      break;
                    case 1:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("marks"))),
                        leading: Icon(Icons.create),
                        onTap: () {
                          if (widget.screen == MarksTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, MarksTab.tag);
                          }
                        },
                      );
                      break;
                    case 2:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("reports"))),
                        leading: Icon(MdiIcons.fileChart),
                        onTap: () {
                          if (widget.screen == ReportsTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, ReportsTab.tag);
                          }
                        },
                      );
                      break;
                    case 3:
                      return ListTile(
                        title:
                            Text(capitalize(getTranslatedString("timetable"))),
                        leading: Icon(Icons.today),
                        onTap: () {
                          if (widget.screen == TimetableTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, TimetableTab.tag);
                          }
                        },
                      );
                      break;
                    case 4:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("exams"))),
                        leading: Icon(MdiIcons.clipboardText),
                        onTap: () {
                          if (widget.screen == ExamsTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, ExamsTab.tag);
                          }
                        },
                      );
                      break;
                    case 5:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("hw"))),
                        leading: Icon(MdiIcons.bagPersonalOutline),
                        onTap: () {
                          if (widget.screen == HomeworkTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, HomeworkTab.tag);
                          }
                        },
                      );
                      break;
                    case 6:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("notices"))),
                        leading: Icon(Icons.layers),
                        onTap: () {
                          if (widget.screen == NoticesTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, NoticesTab.tag);
                          }
                        },
                      );
                      break;
                    case 7:
                      return ListTile(
                        title: Text(capitalize(getTranslatedString("events"))),
                        leading: Icon(MdiIcons.pin),
                        onTap: () {
                          if (widget.screen == EventsTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, EventsTab.tag);
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
                          if (widget.screen == StatisticsTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, StatisticsTab.tag);
                          }
                        },
                      );
                      break;
                    case 9:
                      return ListTile(
                        title:
                            Text(capitalize(getTranslatedString("markCalc"))),
                        leading: new Icon(MdiIcons.calculator),
                        onTap: () {
                          if (widget.screen == CalculatorTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, CalculatorTab.tag);
                          }
                        },
                      );
                      break;
                    case 10:
                      return ListTile(
                        title:
                            Text(capitalize(getTranslatedString("settings"))),
                        leading: Icon(Icons.settings_applications),
                        onTap: () {
                          if (widget.screen == SettingsTab.tag) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushNamed(context, SettingsTab.tag);
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
      ),
    );
  }
}

//TODO Add option to remove items from drawer or reorder cards
