import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/lesson.dart';
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
        itemCount: 9,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await NotificationHelper.show(
                          1,
                          getTranslatedString("testNotif"),
                          getTranslatedString("thisIsHowItWillLookLike"),
                          NotificationHelper.platformChannelSpecificsAlertAll,
                          payload: 'test',
                        );
                      },
                      icon: Icon(
                        MdiIcons.bellRing,
                      ),
                      label: Text(
                        getTranslatedString("sendTestNotif"),
                      ),
                    ),
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'marks ${globals.currentUser.userId} ' +
                                (allParsedByDate.length == 0
                                    ? "0"
                                    : allParsedByDate[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("marks")})",
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'hw ${globals.currentUser.userId} ' +
                                (globalHomework.length == 0
                                    ? "0"
                                    : globalHomework[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("hw")})",
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
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'notice ${globals.currentUser.userId} ' +
                                (allParsedNotices.length == 0
                                    ? "0"
                                    : allParsedNotices[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("notice")})",
                        )),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          String tempIndex = "0";
                          if (lessonsList[0].length > 0) {
                            Lesson tempLesson = lessonsList[0].firstWhere(
                              (element) => element.subject != null,
                              orElse: () => null,
                            );
                            tempIndex =
                                tempLesson != null ? tempLesson.uid : "0";
                          }
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload:
                                'timetable ${globals.currentUser.userId} ' +
                                    tempIndex,
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("timetable")})",
                        )),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'exam ${globals.currentUser.userId} ' +
                                (examsPage.allParsedExams.length == 0
                                    ? "0"
                                    : examsPage.allParsedExams[0].uid
                                        .toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("exam")})",
                        )),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload:
                                'average ${globals.currentUser.userId} ${allParsedSubjectsWithoutZeros[0][0].subject.name}',
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("av")})",
                        )),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'event ${globals.currentUser.userId} ' +
                                (allParsedEvents.length == 0
                                    ? "0"
                                    : allParsedEvents[0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("event")})",
                        )),
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
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                        onPressed: () async {
                          await NotificationHelper.show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            NotificationHelper.platformChannelSpecificsAlertAll,
                            payload: 'absence ${globals.currentUser.userId} ' +
                                (allParsedAbsences.length == 0
                                    ? "0"
                                    : allParsedAbsences[0][0].uid.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                        ),
                        label: Text(
                          getTranslatedString("sendTestNotif") +
                              " (${getTranslatedString("absencesAndDelays")})",
                        )),
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
          itemCount: 5 + (globals.backgroundFetch ? 3 : 0),
          // ignore: missing_return
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
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
                                  builder: (context) => SendTestNotif()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.bellRing,
                          ),
                          label: Text(
                            getTranslatedString("sendTestNotifs"),
                          )),
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
                        FirebaseAnalytics.instance.setUserProperty(
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
                return ListTile(
                  enabled: globals.notifications,
                  title: Text(getTranslatedString("collapseNotifications")),
                  trailing: Switch(
                    onChanged: globals.notifications
                        ? (bool isOn) async {
                            setState(() {
                              globals.collapseNotifications = isOn;
                              globals.prefs
                                  .setBool("collapseNotifications", isOn);
                            });
                          }
                        : null,
                    value: globals.notifications == false
                        ? false
                        : globals.collapseNotifications,
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
                          if (value.length > 6) {
                            return getTranslatedString(
                              "mustBeBetween30And500",
                            );
                          }
                          if (int.parse(value) > 500 || int.parse(value) < 30) {
                            return getTranslatedString("mustBeBetween30And500");
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
                  ],
                );
                break;
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}
