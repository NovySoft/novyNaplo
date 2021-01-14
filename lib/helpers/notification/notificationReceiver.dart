import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/navigation/globalKeyNavigation.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/absences_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart';
import 'package:novynaplo/ui/screens/marks_detail_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/ui/screens/notices_tab.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart';

class NotificationReceiver {
  static Future<void> selectNotification(String payload) async {
    try {
      if (payload == null) {
        return;
      }

      FirebaseCrashlytics.instance
          .log("selectNotification received (payload $payload)");

      globals.notifPayload = payload.toString();
      String payloadPrefix = payload.split(" ")[0];
      String payloadUid;
      int payloadUserId;
      if (payload.split(" ").length > 1) {
        payloadUserId = int.parse(payload.split(" ")[1]);
      }
      if (payload.split(" ").length > 2) {
        payloadUid = payload.split(" ").sublist(2).join();
      }
      //*If content is missing it means, that the user clicked on a "combined" notification and we can just navigate to the according page
      //FIXME: When multiuser support is added we also have to change users. And also make an option to show the data without changing users
      if (payloadUid == null || payloadUid == "") {
        switch (payloadPrefix) {
          case "marks":
            globalWaitAndPushNamed(marksTab.MarksTab.tag);
            break;
          case "hw":
            globalWaitAndPushNamed(HomeworkTab.tag);
            break;
          case "notice":
            globalWaitAndPushNamed(NoticesTab.tag);
            break;
          case "timetable":
            globalWaitAndPushNamed(TimetableTab.tag);
            break;
          case "exam":
            globalWaitAndPushNamed(ExamsTab.tag);
            break;
          case "average":
            globalWaitAndPushNamed(StatisticsTab.tag);
            break;
          case "event":
            globalWaitAndPushNamed(EventsTab.tag);
            break;
          case "absence":
            globalWaitAndPushNamed(AbsencesTab.tag);
            break;
          case "test":
            Fluttertoast.showToast(
              msg: getTranslatedString("pressTestNotif"),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 18.0,
            );
            break;
          default:
            Fluttertoast.showToast(
              msg: getTranslatedString("unkPayload"),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 18.0,
            );
            break;
        }
      } else {
        if (payloadUserId == null) {
          Fluttertoast.showToast(
            msg: getTranslatedString("missingUserId"),
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 18.0,
          );
          return;
        }
        //*If content is suplied, then we should fetch it and show it specifically
        switch (payloadPrefix) {
          case "marks":
            int tempIndex = marksTab.allParsedByDate.indexWhere(
              (element) {
                return element.uid == payloadUid &&
                    element.userId == payloadUserId;
              },
            );
            if (tempIndex == -1) {
              print("NOT FOUND");
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Evals WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more results
                globalWaitAndPushNamed(marksTab.MarksTab.tag);
              } else {
                //*Parse and show
                Evals tempEval = Evals.fromSqlite(maps[0]);
                globalWaitAndPushNamed(marksTab.MarksTab.tag).then(
                  (value) => globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => MarksDetailTab(
                        eval: tempEval,
                        color: getMarkCardColor(
                          eval: tempEval,
                          index: 0,
                        ),
                      ),
                    ),
                  ),
                );
              }
            } else {
              Evals tempEval = marksTab.allParsedByDate[tempIndex];
              globalWaitAndPushNamed(marksTab.MarksTab.tag).then(
                (value) => globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => MarksDetailTab(
                      eval: tempEval,
                      color: getMarkCardColor(
                        eval: tempEval,
                        index: tempIndex,
                      ),
                    ),
                  ),
                ),
              );
            }
            break;
          case "hw":
            globalWaitAndPushNamed(HomeworkTab.tag);
            break;
          case "notice":
            globalWaitAndPushNamed(NoticesTab.tag);
            break;
          case "timetable":
            globalWaitAndPushNamed(TimetableTab.tag);
            break;
          case "exam":
            globalWaitAndPushNamed(ExamsTab.tag);
            break;
          case "average":
            globalWaitAndPushNamed(StatisticsTab.tag);
            break;
          case "event":
            globalWaitAndPushNamed(EventsTab.tag);
            break;
          case "absence":
            globalWaitAndPushNamed(AbsencesTab.tag);
            break;
          default:
            Fluttertoast.showToast(
              msg: getTranslatedString("unkPayload"),
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 18.0,
            );
            break;
        }
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: 'Handle notification select',
        printDetails: true,
      );
    }
  }
}
