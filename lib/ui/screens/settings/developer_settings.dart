import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'dbExplorer/sqlite_viewer.dart';

class DatabaseSettings extends StatefulWidget {
  @override
  _DatabaseSettingsState createState() => _DatabaseSettingsState();
}

class _DatabaseSettingsState extends State<DatabaseSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("dbSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "SQLITE " + getTranslatedString("db"),
                          style: new TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getTranslatedString("onlyAdvanced"),
                          style: new TextStyle(fontSize: 20, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return AlertDialog(
                                  elevation: globals.darker ? 0 : 24,
                                  title:
                                      new Text(getTranslatedString("delete")),
                                  content: Text(
                                    getTranslatedString("sureDeleteDB"),
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(getTranslatedString("yes"),
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        FirebaseAnalytics()
                                            .logEvent(name: "clear_database");
                                        FirebaseCrashlytics.instance
                                            .log("clear_database");
                                        await DatabaseHelper.clearAllTables();
                                        Navigator.of(context).pop();
                                        _ackAlert(context,
                                            "Adatbázis sikeresen törölve");
                                      },
                                    ),
                                    TextButton(
                                      child: Text(getTranslatedString("no")),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseRemove,
                          ),
                          label: Text(
                            getTranslatedString("deleteDB"),
                          )),
                    ),
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RawSqlQuery()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseImport,
                          ),
                          label: Text(
                            getTranslatedString("runRawSQL"),
                          )),
                    ),
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DatabaseList()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseSearch,
                          ),
                          label: Text(
                            getTranslatedString("dbExplorer"),
                          )),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
                break;
            }
          }),
    );
  }
}

class RawSqlQuery extends StatefulWidget {
  @override
  _RawSqlQueryState createState() => _RawSqlQueryState();
}

class _RawSqlQueryState extends State<RawSqlQuery> {
  TextEditingController _sqlController = new TextEditingController();
  FocusNode _sqlFocus = new FocusNode();
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(getTranslatedString("runRawSQL")),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            controller: _sqlController,
            focusNode: _sqlFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (term) async {
              try {
                final Database db = globals.db;
                if (term.toLowerCase().contains("insert")) {
                  int tempId = await db.rawInsert(term);
                  result = "inserted at id: " + tempId.toString();
                } else if (term.toLowerCase().contains("delete")) {
                  int tempId = await db.rawDelete(term);
                  result = tempId.toString() + " items deleted";
                } else if (term.toLowerCase().contains("select")) {
                  var temp = await db.rawQuery(term);
                  JsonEncoder encoder = new JsonEncoder.withIndent('  ');
                  String prettyprint = encoder.convert(temp);
                  result = prettyprint;
                } else if (term.toLowerCase().contains("update")) {
                  int tempId = await db.rawUpdate(term);
                  result = tempId.toString() + " items modified";
                }
              } catch (e) {
                result = e.toString();
              }
              setState(() {
                result = result;
              });
              _sqlFocus.unfocus();
            },
          ),
          SizedBox(height: 15),
          DecoratedBox(
            decoration: new BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                left: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                right: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                bottom: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
              ),
            ),
            child: SizedBox(
              height: 250,
              child: ListView(
                children: [
                  SelectableText(
                    result,
                    toolbarOptions: ToolbarOptions(copy: true, selectAll: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperSettings extends StatefulWidget {
  @override
  _DeveloperSettingsState createState() => _DeveloperSettingsState();
}

class _DeveloperSettingsState extends State<DeveloperSettings> {
  bool _checkForUpdates = true;
  bool _checkForTestVersions = false;

  @override
  void initState() {
    _checkForUpdates = globals.prefs.get("checkForUpdates") ?? true;
    _checkForTestVersions = globals.prefs.get("checkForTestVersions") ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(getTranslatedString("developerSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          getTranslatedString("developerSettings"),
                          style: new TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getTranslatedString("developerSettingsWarning"),
                          style: new TextStyle(fontSize: 20, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DatabaseSettings()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseEdit,
                          ),
                          label: Text(
                            getTranslatedString("dbSettings"),
                          )),
                    ),
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text(getTranslatedString("checkForUpdates")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      setState(() {
                        _checkForUpdates = switchOn;
                      });
                      await globals.prefs.setBool("checkForUpdates", switchOn);
                      FirebaseCrashlytics.instance
                          .setCustomKey("checkForUpdates", switchOn);
                    },
                    value: _checkForUpdates,
                  ),
                );
                break;
              case 3:
                if (_checkForUpdates)
                  return ListTile(
                    title: Text(getTranslatedString("checkForTestVersions")),
                    trailing: Switch(
                      onChanged: (bool switchOn) async {
                        setState(() {
                          _checkForTestVersions = switchOn;
                        });
                        await globals.prefs
                            .setBool("checkForTestVersions", switchOn);
                        FirebaseCrashlytics.instance
                            .setCustomKey("checkForTestVersions", switchOn);
                      },
                      value: _checkForTestVersions,
                    ),
                  );
                else
                  return SizedBox(height: 0, width: 0);
                break;
              default:
                return SizedBox(height: 10, width: 10);
                break;
            }
          }),
    );
  }
}

Future<void> _ackAlert(BuildContext context, String content) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: globals.darker ? 0 : 24,
        title: Text(getTranslatedString("status")),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
