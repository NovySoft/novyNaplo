import 'package:connectivity/connectivity.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/screens/timetable_detail_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:novynaplo/global.dart' as globals;

List<List<Lesson>> lessonsList = [];
List<DateTime> fetchedDayList = [];
var selectedLessonList = [];
int i = 0;
DateTime _selectedDate = DateTime.now();
var alma = DateTime.monday;
final CalendarWeekController _controller = CalendarWeekController();
bool fade = true;
DateTime minDate;

class TimetableTab extends StatefulWidget {
  static String tag = 'timetable';
  @override
  _TimetableTabState createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Timetable");
    _selectedDate = DateTime.now();
    if (globals.payloadId != -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Lesson tempLesson;
        int jI = -1;
        for (var n in lessonsList) {
          for (var j in n) {
            jI++;
            if (tempLesson != null) break;
            if (j.id == globals.payloadId) {
              tempLesson = j;
              break;
            }
          }
          if (tempLesson != null) break;
        }
        _controller.jumpToDate(tempLesson.date);
        setState(() {
          _selectedDate = tempLesson.date;
        });
        globals.payloadId = -1;
        Color color;
        if (jI >= marksPage.colors.length) {
          color = getRandomColors(1)[0];
          marksPage.colors.add(color);
        } else {
          color = marksPage.colors[jI];
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimetableDetailTab(
              icon: tempLesson.homework.icon,
              color: color,
              lessonInfo: tempLesson,
            ),
          ),
        );
      });
    }
    //TODO Go to current day when opening
    super.initState();
  }

  Future<void> handleDateChange(DateTime datetime, BuildContext context) async {
    setState(() {
      fade = false;
    });
    await sleep(250);
    setState(() {
      _selectedDate = datetime;
      fade = true;
    });
    if (fetchedDayList
            .where((item) =>
                item.day == _selectedDate.day &&
                item.month == _selectedDate.month &&
                item.year == _selectedDate.year)
            .length ==
        0) {
      if (await NetworkHelper().isNetworkAvailable() ==
          ConnectivityResult.none) {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) {
              return AlertDialog(
                title: Text(getTranslatedString("status")),
                content: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Text("${getTranslatedString("noNet")}:"),
                  ]),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      } else {
        showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) {
              return SpinnerDialog();
            });
        try {
          lessonsList.addAll(
              await NetworkHelper().getSpecifiedWeeksLesson(_selectedDate));
          setState(() {
            _selectedDate = datetime;
          });
          Navigator.of(login.keyLoader.currentContext, rootNavigator: true)
              .pop();
        } catch (e) {
          await sleep(500);
          Navigator.of(login.keyLoader.currentContext, rootNavigator: true)
              .pop();
          showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) {
                return AlertDialog(
                  title: Text(getTranslatedString("status")),
                  content: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Text("${getTranslatedString("err")}"),
                      Text(e.toString()),
                    ]),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    selectedLessonList = List.from(lessonsList.where((element) {
      if (element == null || element.length == 0) {
        return false;
      }
      return element[0].date.year == _selectedDate.year &&
          element[0].date.month == _selectedDate.month &&
          element[0].date.day == _selectedDate.day;
    }));
    if (selectedLessonList.length != 0) {
      selectedLessonList = selectedLessonList[0];
    }
    if (minDate == null) {
      minDate = DateTime.now().subtract(Duration(days: 365));
      while (minDate.weekday != DateTime.monday) {
        minDate = minDate.subtract(new Duration(days: 1));
      }
    }
    return Scaffold(
      drawer: getDrawer(TimetableTab.tag, context),
      appBar: AppBar(
        title: new Text(capitalize(getTranslatedString("timetable"))),
      ),
      body: Column(children: [
        CalendarWeek(
          controller: _controller,
          height: 100,
          minDate: minDate,
          maxDate: DateTime.now().add(
            Duration(days: 365),
          ),
          onDatePressed: (DateTime datetime) async {
            await handleDateChange(datetime, context);
          },
          onDateLongPressed: (DateTime datetime) async {
            await handleDateChange(datetime, context);
          },
          onWeekChanged: () {},
          weekendsStyle:
              TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          dayOfWeekStyle:
              TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          dayOfWeekAlignment: FractionalOffset.bottomCenter,
          dateAlignment: FractionalOffset.topCenter,
          pressedDateBackgroundColor: Colors.blue,
          pressedDateStyle:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
          dateBackgroundColor: Colors.transparent,
          backgroundColor:
              DynamicTheme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
          dayOfWeek: [
            getTranslatedString('MON'),
            getTranslatedString('TUE'),
            getTranslatedString('WED'),
            getTranslatedString('THU'),
            getTranslatedString('FRI'),
            getTranslatedString('SAT'),
            getTranslatedString('SUN'),
          ],
          month: [
            getTranslatedString("January"),
            getTranslatedString("February"),
            getTranslatedString("March"),
            getTranslatedString("April"),
            getTranslatedString("May"),
            getTranslatedString("June"),
            getTranslatedString("July"),
            getTranslatedString("August"),
            getTranslatedString("September"),
            getTranslatedString("October"),
            getTranslatedString("November"),
            getTranslatedString("December"),
          ],
          showMonth: true,
          spaceBetweenLabelAndDate: 0,
          dayShapeBorder: CircleBorder(),
          decorations: [
            DecorationItem(
              decorationAlignment: FractionalOffset.bottomRight,
              date: DateTime.now(),
              decoration: Icon(
                Icons.today,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            height: 2.0,
            width: double.infinity,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Center(
            child: AnimatedOpacity(
              opacity: fade ? 1 : 0,
              duration: Duration(milliseconds: 250),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) async {
                  /*if (details.velocity.pixelsPerSecond.dx > 0) {
                    setState(() {
                      fade = false;
                    });
                    await sleep(250);
                    setState(() {
                      _selectedDate = _selectedDate.subtract(Duration(days: 1));
                      fade = true;
                    });
                  } else if (details.velocity.pixelsPerSecond.dx < 0) {
                    setState(() {
                      fade = false;
                    });
                    await sleep(250);
                    setState(() {
                      _selectedDate = _selectedDate.add(Duration(days: 1));
                      fade = true;
                    });
                  }*/
                },
                child: selectedLessonList.length == 0
                    ? SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              MdiIcons.emoticonHappyOutline,
                              size: 50,
                            ),
                            Text("${getTranslatedString("noLesson")}!")
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedLessonList.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index >= selectedLessonList.length) {
                            return SizedBox(
                              height: 100,
                            );
                          }
                          Color color;
                          if (index >= marksPage.colors.length) {
                            color = getRandomColors(1)[0];
                            marksPage.colors.add(color);
                          } else {
                            color = marksPage.colors[index];
                          }
                          return SafeArea(
                            child: TimetableCard(
                              iconData: selectedLessonList[index].homework.icon,
                              hasHomework:
                                  selectedLessonList[index].homework.content !=
                                      null,
                              color: color,
                              heroAnimation: AlwaysStoppedAnimation(0),
                              lessonInfo: selectedLessonList[index],
                              onPressed: TimetableDetailTab(
                                icon: selectedLessonList[index].homework.icon,
                                color: color,
                                lessonInfo: selectedLessonList[index],
                              ),
                            ),
                          );
                        }),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
