import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/main.dart' as main;
import '../events_tab.dart';
import '../notices_tab.dart';
import '../timetable_tab.dart';
import 'package:novynaplo/helpers/backgroundFetchHelper.dart'
    as backgroundFetchHelper;

TextEditingController fetchPeriodController =
    TextEditingController(text: globals.fetchPeriod.toString());

class FormKey {
  static final formKeyTwo = GlobalKey<FormState>(debugLabel: '_FormKey2');
}

class SendTestNotif extends StatefulWidget {
  @override
  _SendTestNotifState createState() => _SendTestNotifState();
}

class _SendTestNotifState extends State<SendTestNotif> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("sendTestNotifs")),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: 9 + globals.adModifier,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'teszt',
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(getTranslatedString("sendTestNotif"),
                            style: TextStyle(color: Colors.black))),
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'marks ' +
                                (allParsedByDate.length == 0
                                    ? "0"
                                    : allParsedByDate[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("marks")})",
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'hw ' +
                                (globalHomework.length == 0
                                    ? "0"
                                    : globalHomework[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("hw")})",
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'notice ' +
                                (allParsedNotices.length == 0
                                    ? "0"
                                    : allParsedNotices[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("notice")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 4:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'timetable ' +
                                (lessonsList[0].length == 0
                                    ? "0"
                                    : lessonsList[0][0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("timetable")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 5:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'exam ' +
                                (examsPage.allParsedExams.length == 0
                                    ? "0"
                                    : examsPage.allParsedExams[0].uid
                                        .toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("exam")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 6:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload:
                                'average ${allParsedSubjectsWithoutZeros[0][0].subject.name}',
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("av")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 7:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'event ' +
                                (allParsedEvents.length == 0
                                    ? "0"
                                    : allParsedEvents[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("event")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 8:
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
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecifics,
                            payload: 'absence ' +
                                (allParsedAbsences.length == 0
                                    ? "0"
                                    : allParsedAbsences[0][0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("absencesAndDelays")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            default:
              return SizedBox(height: 100);
          }
        },
      ),
    );
  }
}

class NetworkAndNotificationSettings extends StatefulWidget {
  @override
  _NetworkAndNotificationSettingsState createState() =>
      _NetworkAndNotificationSettingsState();
}

class _NetworkAndNotificationSettingsState
    extends State<NetworkAndNotificationSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("networkAndNotificationSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4 + (globals.backgroundFetch ? 3 : 0),
          // ignore: missing_return
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
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
                                  builder: (context) => SendTestNotif()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.bellRing,
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("sendTestNotifs"),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text(getTranslatedString("notifications")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      setState(() {
                        globals.notifications = isOn;
                        globals.prefs.setBool("notifications", isOn);
                        FirebaseCrashlytics.instance
                            .setCustomKey("notifications", isOn);
                        FirebaseAnalytics().setUserProperty(
                          name: "Notifications",
                          value: isOn ? "ON" : "OFF",
                        );
                      });
                    },
                    value: globals.notifications,
                  ),
                );
                break;
              case 2:
                //*asd
                return ListTile(
                  title: Text(getTranslatedString("verCheckOnStart")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      setState(() {
                        globals.verCheckOnStart = isOn;
                        globals.prefs.setBool("getVersion", isOn);
                      });
                    },
                    value: globals.verCheckOnStart,
                  ),
                );
                break;
              case 3:
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(getTranslatedString("backgroundFetch")),
                      trailing: Switch(
                        onChanged: (bool isOn) async {
                          setState(() {
                            globals.backgroundFetch = isOn;
                            globals.prefs.setBool("backgroundFetch", isOn);
                            FirebaseCrashlytics.instance
                                .setCustomKey("backgroundFetch", isOn);
                          });
                          if (isOn) {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            FirebaseCrashlytics.instance.log(
                                "Canceled alarm: " +
                                    main.fetchAlarmID.toString());
                            await delay(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          } else {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            FirebaseCrashlytics.instance.log(
                                "Canceled alarm: " +
                                    main.fetchAlarmID.toString());
                            await delay(1500);
                            main.fetchAlarmID++;
                          }
                        },
                        value: globals.backgroundFetch,
                      ),
                    ),
                    SizedBox(height: globals.backgroundFetch ? 0 : 100),
                  ],
                );
                break;
              case 4:
                return ListTile(
                  title: Text(getTranslatedString("backgroundFetchOnCellular")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      setState(() {
                        globals.backgroundFetchOnCellular = isOn;
                        globals.prefs
                            .setBool("backgroundFetchOnCellular", isOn);
                        FirebaseCrashlytics.instance
                            .setCustomKey("backgroundFetchOnCellular", isOn);
                      });
                    },
                    value: globals.backgroundFetchOnCellular,
                  ),
                );
                break;
              case 5:
                return ListTile(
                  title: Text(
                      "${getTranslatedString("timeBetweenFetches")} (30-500${getTranslatedString("minutes")}):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: FormKey.formKeyTwo,
                      child: TextFormField(
                        controller: fetchPeriodController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslatedString("cantLeaveEmpty");
                          }
                          if (int.parse(value) > 500 || int.parse(value) < 30) {
                            return getTranslatedString("mustBeBetween30And50");
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (FormKey.formKeyTwo.currentState.validate()) {
                            globals.prefs
                                .setInt("fetchPeriod", int.parse(input));
                            globals.fetchPeriod = int.parse(input);
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            FirebaseCrashlytics.instance.log(
                                "Canceled alarm: " +
                                    main.fetchAlarmID.toString());
                            await delay(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              case 6:
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(getTranslatedString("fetchWakePhone")),
                      trailing: Switch(
                        onChanged: (bool isOn) async {
                          setState(() {
                            globals.backgroundFetchCanWakeUpPhone = isOn;
                            globals.prefs
                                .setBool("backgroundFetchCanWakeUpPhone", isOn);
                            FirebaseCrashlytics.instance.setCustomKey(
                                "backgroundFetchCanWakeUpPhone", isOn);
                          });
                          if (isOn) {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            FirebaseCrashlytics.instance.log(
                                "Canceled alarm: " +
                                    main.fetchAlarmID.toString());
                            await delay(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          } else {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            FirebaseCrashlytics.instance.log(
                                "Canceled alarm: " +
                                    main.fetchAlarmID.toString());
                            await delay(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          }
                        },
                        value: globals.backgroundFetchCanWakeUpPhone,
                      ),
                    ),
                    SizedBox(height: 100, width: 10),
                  ],
                );
                break;
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}
