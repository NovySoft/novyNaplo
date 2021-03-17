import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/waitWhile.dart';
import 'package:novynaplo/helpers/navigation/globalKeyNavigation.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesTab;
import 'package:novynaplo/ui/screens/charts_detail_tab.dart';
import 'package:novynaplo/ui/screens/events_detail_tab.dart';
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsTab;
import 'package:novynaplo/ui/screens/exams_detail_tab.dart';
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsTab;
import 'package:novynaplo/ui/screens/homework_detail_tab.dart';
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkTab;
import 'package:novynaplo/ui/screens/marks_detail_tab.dart';
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/ui/screens/notices_detail_tab.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesTab;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statsTab;
import 'package:novynaplo/ui/screens/timetable_detail_tab.dart';
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetableTab;
import 'notificationHelper.dart';
//FIXME: Do not use random colors

class NotificationReceiver {
  //!THIS DOESN'T WORK WITH MULTIUSER
  static Future<void> selectNotification(
    String payload,
    bool appLaunchedApp,
  ) async {
    await waitUntil(() => globals.isDataLoaded);
    try {
      if (payload == null) {
        return;
      }

      FirebaseCrashlytics.instance
          .log("selectNotification received (payload $payload)");

      String payloadPrefix = payload.split(" ")[0];
      String payloadUid;
      int payloadUserId;
      //?prefix userId uid
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
            if (!appLaunchedApp) globalWaitAndPushNamed(marksTab.MarksTab.tag);
            break;
          case "hw":
            globalWaitAndPushNamed(homeworkTab.HomeworkTab.tag);
            break;
          case "notice":
            globalWaitAndPushNamed(noticesTab.NoticesTab.tag);
            break;
          case "timetable":
            globalWaitAndPushNamed(timetableTab.TimetableTab.tag);
            break;
          case "exam":
            globalWaitAndPushNamed(examsTab.ExamsTab.tag);
            break;
          case "average":
            //No need to go to the average tab, we show the multichart graph
            globalWaitAndPushNamed(statsTab.StatisticsTab.tag);
            break;
          case "event":
            globalWaitAndPushNamed(eventsTab.EventsTab.tag);
            break;
          case "absence":
            globalWaitAndPushNamed(statsTab.StatisticsTab.tag).then(
              (value) => globalWaitAndPushNamed(absencesTab.AbsencesTab.tag),
            );
            break;
          case "test":
            ErrorToast.showErrorToast(getTranslatedString("pressTestNotif"));
            break;
          default:
            ErrorToast.showErrorToast(getTranslatedString("unkPayload"));
            break;
        }
      } else {
        if (payloadUserId == null) {
          ErrorToast.showErrorToast(getTranslatedString("missingUserId"));
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
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Evals WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(marksTab.MarksTab.tag);
              } else {
                //*Parse and show from database
                Evals tempEval = Evals.fromSqlite(maps[0]);
                if (appLaunchedApp) {
                  globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => MarksDetailTab(
                        eval: tempEval,
                        color: getMarkCardColor(
                          eval: tempEval,
                          index: 0,
                        ),
                      ),
                    ),
                  );
                } else {
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
              }
            } else {
              //?Data is in the parsed list
              Evals tempEval = marksTab.allParsedByDate[tempIndex];
              if (appLaunchedApp) {
                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => MarksDetailTab(
                      eval: tempEval,
                      color: getMarkCardColor(
                        eval: tempEval,
                        index: tempIndex,
                      ),
                    ),
                  ),
                );
              } else {
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
            }
            break;
          case "hw":
            int tempIndex = homeworkTab.globalHomework.indexWhere(
              (element) {
                return element.uid == payloadUid &&
                    element.userId == payloadUserId;
              },
            );
            if (tempIndex == -1) {
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Homework WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(homeworkTab.HomeworkTab.tag);
              } else {
                //*Parse and show from database
                Homework tempHw = Homework.fromSqlite(maps[0]);
                globalWaitAndPushNamed(homeworkTab.HomeworkTab.tag).then(
                  (value) => globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => HomeworkDetailTab(
                        hwInfo: tempHw,
                        color: getRandomColors(1)[0],
                      ),
                    ),
                  ),
                );
              }
            } else {
              //?Data is in the parsed list
              Homework tempHw = homeworkTab.globalHomework[tempIndex];
              globalWaitAndPushNamed(homeworkTab.HomeworkTab.tag).then(
                (value) => globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => HomeworkDetailTab(
                      hwInfo: tempHw,
                      color: homeworkTab.colors.length <= tempIndex
                          ? getRandomColors(1)[0]
                          : homeworkTab.colors[tempIndex],
                    ),
                  ),
                ),
              );
            }
            break;
          case "notice":
            int tempIndex = noticesTab.allParsedNotices.indexWhere(
              (element) {
                return element.uid == payloadUid &&
                    element.userId == payloadUserId;
              },
            );
            if (tempIndex == -1) {
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Notices WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(noticesTab.NoticesTab.tag);
              } else {
                //*Parse and show from database
                Notice tempNotice = Notice.fromSqlite(maps[0]);
                globalWaitAndPushNamed(noticesTab.NoticesTab.tag).then(
                  (value) => globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => NoticeDetailTab(
                        notice: tempNotice,
                        color: getRandomColors(1)[0],
                      ),
                    ),
                  ),
                );
              }
            } else {
              //?Data is in the parsed list
              Notice tempNotice = noticesTab.allParsedNotices[tempIndex];
              globalWaitAndPushNamed(noticesTab.NoticesTab.tag).then(
                (value) => globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => NoticeDetailTab(
                      notice: tempNotice,
                      color: noticesTab.colors.length <= tempIndex
                          ? getRandomColors(1)[0]
                          : noticesTab.colors[tempIndex],
                    ),
                  ),
                ),
              );
            }
            break;
          case "timetable":
            Lesson tempLesson = timetableTab.lessonsList
                .expand((element) => element)
                .firstWhere((element) {
              return element.uid == payloadUid &&
                  element.userId == payloadUserId;
            }, orElse: () {
              return null;
            });

            if (tempLesson == null) {
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Timetable WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(timetableTab.TimetableTab.tag);
              } else {
                Lesson tempLesson = Lesson.fromSqlite(maps[0]);
                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => timetableTab.TimetableTab(
                      jumpToDate: tempLesson.date,
                    ),
                  ),
                ).then((value) {
                  globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => TimetableDetailTab(
                        icon: tempLesson.icon,
                        color: getRandomColors(1)[0],
                        lessonInfo: tempLesson,
                      ),
                    ),
                  );
                });
              }
            } else {
              List<Lesson> _tempList = timetableTab.lessonsList.firstWhere(
                  (element) => element[0].date.isSameDay(tempLesson.date));
              int colorIndex = _tempList.indexWhere((element) =>
                  element.uid == payloadUid && element.userId == payloadUserId);
              globalWaitAndPush(
                MaterialPageRoute(
                  builder: (context) => timetableTab.TimetableTab(
                    jumpToDate: tempLesson.date,
                  ),
                ),
              ).then((value) {
                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => TimetableDetailTab(
                      icon: tempLesson.icon,
                      color: marksTab.colors[colorIndex],
                      lessonInfo: tempLesson,
                    ),
                  ),
                );
              });
            }
            break;
          case "exam":
            int tempIndex = examsTab.allParsedExams.indexWhere(
              (element) {
                return element.uid == payloadUid &&
                    element.userId == payloadUserId;
              },
            );
            if (tempIndex == -1) {
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Exams WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(examsTab.ExamsTab.tag);
              } else {
                //*Parse and show from database
                Exam tempExam = Exam.fromSqlite(maps[0]);
                globalWaitAndPushNamed(examsTab.ExamsTab.tag).then(
                  (value) => globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => ExamsDetailTab(
                        exam: tempExam,
                        color: getRandomColors(1)[0],
                      ),
                    ),
                  ),
                );
              }
            } else {
              //?Data is in the parsed list
              Exam tempExam = examsTab.allParsedExams[tempIndex];
              globalWaitAndPushNamed(examsTab.ExamsTab.tag).then(
                (value) => globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => ExamsDetailTab(
                      exam: tempExam,
                      color: examsTab.colors.length <= tempIndex
                          ? getRandomColors(1)[0]
                          : examsTab.colors[tempIndex],
                    ),
                  ),
                ),
              );
            }
            break;
          case "average":
            int tempIndex = statsTab.allParsedSubjectsWithoutZeros
                .indexWhere((element) => element[0].subject.name == payloadUid);

            if (tempIndex == -1) {
              List<Evals> _tempEvals = await DatabaseHelper.getAllEvals();
              List<List<Evals>> _tempMatrix =
                  categorizeSubjectsFromEvals(_tempEvals);
              List<List<Evals>> _tempMatrixWithoutZeros = List.from(
                _tempMatrix.where((element) => element[0].numberValue != 0),
              );
              int tempIndexTwo = _tempMatrixWithoutZeros.indexWhere(
                (element) => element[0].subject.name == payloadUid,
              );
              if (tempIndexTwo == -1) {
                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => statsTab.StatisticsTab(
                      startOnSubjects: true,
                    ),
                  ),
                );
              } else {
                Color currColor = marksTab.colors[tempIndexTwo + 1];

                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => statsTab.StatisticsTab(
                      startOnSubjects: true,
                    ),
                  ),
                ).then((value) {
                  globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => ChartsDetailTab(
                        id: tempIndexTwo,
                        subject: capitalize(
                            _tempMatrixWithoutZeros[tempIndexTwo][0]
                                .subject
                                .name),
                        color: currColor,
                        inputList: _tempMatrixWithoutZeros[tempIndexTwo],
                        animate: globals.chartAnimations,
                      ),
                    ),
                  );
                });
              }
            } else {
              Color currColor = marksTab.colors[tempIndex + 1];

              globalWaitAndPush(
                MaterialPageRoute(
                  builder: (context) => statsTab.StatisticsTab(
                    startOnSubjects: true,
                  ),
                ),
              ).then((value) {
                globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => ChartsDetailTab(
                      id: tempIndex,
                      subject: capitalize(statsTab
                          .allParsedSubjectsWithoutZeros[tempIndex][0]
                          .subject
                          .name),
                      color: currColor,
                      inputList:
                          statsTab.allParsedSubjectsWithoutZeros[tempIndex],
                      animate: globals.chartAnimations,
                    ),
                  ),
                );
              });
            }

            break;
          case "event":
            int tempIndex = eventsTab.allParsedEvents.indexWhere(
              (element) {
                return element.uid == payloadUid &&
                    element.userId == payloadUserId;
              },
            );
            if (tempIndex == -1) {
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Events WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(eventsTab.EventsTab.tag);
              } else {
                //*Parse and show from database
                Event tempEvent = Event.fromSqlite(maps[0]);
                globalWaitAndPushNamed(eventsTab.EventsTab.tag).then(
                  (value) => globalWaitAndPush(
                    MaterialPageRoute(
                      builder: (context) => EventsDetailTab(
                        eventDetails: tempEvent,
                        color: getRandomColors(1)[0],
                      ),
                    ),
                  ),
                );
              }
            } else {
              //?Data is in the parsed list
              Event tempEvent = eventsTab.allParsedEvents[tempIndex];
              globalWaitAndPushNamed(eventsTab.EventsTab.tag).then(
                (value) => globalWaitAndPush(
                  MaterialPageRoute(
                    builder: (context) => EventsDetailTab(
                      eventDetails: tempEvent,
                      color: eventsTab.colors.length <= tempIndex
                          ? getRandomColors(1)[0]
                          : eventsTab.colors[tempIndex],
                    ),
                  ),
                ),
              );
            }
            break;
          case "absence":
            Absence tempItem = absencesTab.allParsedAbsences
                .expand((element) => element)
                .firstWhere((element) {
              return element.uid == payloadUid &&
                  element.userId == payloadUserId;
            }, orElse: () {
              return null;
            });

            if (tempItem == null) {
              //?Strange, data was not found in the loaded items
              final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
                'SELECT * FROM Absences WHERE userId = ? and uid = ? GROUP BY uid, userId',
                [payloadUserId, payloadUid],
              );
              if (maps.length != 1) {
                //?0 or more than 1 result
                globalWaitAndPushNamed(statsTab.StatisticsTab.tag).then(
                  (value) => globalWaitAndPushNamed(
                    absencesTab.AbsencesTab.tag,
                  ),
                );
              } else {
                //*Parse and show from database
                Absence tempAbsence = Absence.fromSqlite(maps[0]);
                globalWaitAndPushNamed(statsTab.StatisticsTab.tag)
                    .then(
                      (value) => globalWaitAndPushNamed(
                        absencesTab.AbsencesTab.tag,
                      ),
                    )
                    .then(
                      (value) => globalWaitAndPush(
                        MaterialPageRoute(
                          builder: (context) =>
                              absencesTab.AbsencencesDetailTab(
                            absence: tempAbsence,
                            color: getAbsenceCardColor(tempAbsence),
                          ),
                        ),
                      ),
                    );
              }
            } else {
              //?Data is in the parsed list
              globalWaitAndPushNamed(statsTab.StatisticsTab.tag)
                  .then(
                    (value) => globalWaitAndPushNamed(
                      absencesTab.AbsencesTab.tag,
                    ),
                  )
                  .then(
                    (value) => globalWaitAndPush(
                      MaterialPageRoute(
                        builder: (context) => absencesTab.AbsencencesDetailTab(
                          absence: tempItem,
                          color: getAbsenceCardColor(tempItem),
                        ),
                      ),
                    ),
                  );
            }
            break;
          default:
            ErrorToast.showErrorToast(getTranslatedString("unkPayload"));
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
    } finally {
      if (appLaunchedApp) {
        NotificationHelper.didNotificationLaunchApp = false;
      }
    }
  }
}
