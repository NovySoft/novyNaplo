import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/database/mainSql.dart' as mainSql;

import 'dbExplorer/sqlite_viewer.dart';

class DatabaseSettings extends StatefulWidget {
  @override
  _DatabaseSettingsState createState() => _DatabaseSettingsState();
}

class _DatabaseSettingsState extends State<DatabaseSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("dbSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4 + globals.adModifier,
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
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return AlertDialog(
                                  title:
                                      new Text(getTranslatedString("delete")),
                                  content: Text(
                                    getTranslatedString("sureDeleteDB"),
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(getTranslatedString("yes"),
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        FirebaseAnalytics()
                                            .logEvent(name: "clear_database");
                                        FirebaseCrashlytics.instance
                                            .log("clear_database");
                                        await clearAllTables();
                                        Navigator.of(context).pop();
                                        _ackAlert(context,
                                            "Adatbázis sikeresen törölve");
                                      },
                                    ),
                                    FlatButton(
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
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("deleteDB"),
                              style: TextStyle(color: Colors.black))),
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
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
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
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("runRawSQL"),
                              style: TextStyle(color: Colors.black))),
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
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DatabaseList()),
                            );
                          },
                          icon: Icon(MdiIcons.databaseSearch,
                              color: Colors.black),
                          label: Text(getTranslatedString("dbExplorer"),
                              style: TextStyle(color: Colors.black))),
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
              final Database db = await mainSql.database;
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
              setState(() {
                result = result;
              });
              _sqlFocus.unfocus();
            },
          ),
          SizedBox(height: 15),
          DecoratedBox(
            decoration: new BoxDecoration(border: Border.all()),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(getTranslatedString("developerSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 3 + globals.adModifier,
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
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DatabaseSettings()),
                            );
                          },
                          icon:
                              Icon(MdiIcons.databaseEdit, color: Colors.black),
                          label: Text(getTranslatedString("dbSettings"),
                              style: TextStyle(color: Colors.black))),
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

Future<void> _ackAlert(BuildContext context, String content) async {
  return showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(getTranslatedString("status")),
        content: Text(content),
        actions: <Widget>[
          FlatButton(
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
