import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/ui/cardColor/timetableCard.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as login;
import 'package:novynaplo/ui/screens/timetable_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/widgets/AnimatedTimetableCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/ui/widgets/LoadingSpinner.dart';
import 'package:novynaplo/data/models/extensions.dart';

List<List<Lesson>> lessonsList = [];
List<DateTime> fetchedDayList = [];
Lesson specialEventDay;
var selectedLessonList = [];
int i = 0;
DateTime _selectedDate = DateTime.now();
var alma = DateTime.monday;
final CalendarWeekController _controller = CalendarWeekController();
bool fade = true;
DateTime minDate;

class TimetableTab extends StatefulWidget {
  TimetableTab({this.jumpToDate});

  static String tag = 'timetable';
  final DateTime jumpToDate;

  @override
  _TimetableTabState createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Timetable");
    _selectedDate = DateTime.now();
    if (widget.jumpToDate != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.jumpToDate(widget.jumpToDate);
        setState(() {
          _selectedDate = widget.jumpToDate;
        });
      });
    }
    super.initState();
  }

  Future<void> handleDateChange(DateTime datetime, BuildContext context) async {
    setState(() {
      fade = false;
    });
    await delay(250);
    setState(() {
      _selectedDate = datetime;
      fade = true;
    });
    if (fetchedDayList
            .where(
              (item) => item.isSameDay(_selectedDate),
            )
            .length ==
        0) {
      if (!(await NetworkHelper.isNetworkAvailable())) {
        showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) {
              return AlertDialog(
                elevation: globals.darker ? 0 : 24,
                title: Text(getTranslatedString("status")),
                content: SingleChildScrollView(
                  child: Column(children: <Widget>[
                    Text("${getTranslatedString("noNet")}:"),
                  ]),
                ),
                actions: <Widget>[
                  TextButton(
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
              return LoadingSpinner();
            });
        try {
          List<List<Lesson>> tempLessonList =
              await RequestHandler.getSpecifiedWeeksLesson(
            globals.currentUser,
            date: _selectedDate,
          );
          if (tempLessonList == null) {
            throw "Invalid server response!";
          }
          lessonsList.addAll(tempLessonList);
          setState(() {
            _selectedDate = datetime;
          });
          Navigator.of(
            login.KeyLoaderKey.keyLoader.currentContext,
            rootNavigator: true,
          ).pop();
        } catch (e) {
          await delay(500);
          Navigator.of(
            login.KeyLoaderKey.keyLoader.currentContext,
            rootNavigator: true,
          ).pop();
          showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (_) {
                return AlertDialog(
                  elevation: globals.darker ? 0 : 24,
                  title: Text(getTranslatedString("status")),
                  content: SingleChildScrollView(
                    child: Column(children: <Widget>[
                      Text("${getTranslatedString("err")}"),
                      Text(e.toString()),
                    ]),
                  ),
                  actions: <Widget>[
                    TextButton(
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
    //Get only the selected dates
    selectedLessonList = List.from(lessonsList.where((element) {
      if (element == null || element.length == 0) {
        return false;
      }
      return element[0].date.isSameDay(_selectedDate);
    }));
    //It is only a 1*n matrix so we get that
    if (selectedLessonList.length != 0) {
      selectedLessonList = selectedLessonList[0];
    }
    //Is it a special day?
    bool selected = false;
    List<dynamic> temp = List.from(selectedLessonList);
    temp.removeWhere((element) {
      if (element.isSpecialDayEvent) {
        specialEventDay = element;
        selected = true;
      }
      return element.isSpecialDayEvent;
    });
    selectedLessonList = temp;
    if (!selected) {
      specialEventDay = null;
    }
    //Get min date
    if (minDate == null) {
      minDate = DateTime.now().subtract(Duration(days: 365));
      while (minDate.weekday != DateTime.monday) {
        minDate = minDate.subtract(new Duration(days: 1));
      }
    }
    return Scaffold(
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(TimetableTab.tag),
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
          backgroundColor: globals.darker
              ? Colors.black
              : DynamicTheme.of(context).themeMode == ThemeMode.light
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
          height: 7,
        ),
        AnimatedOpacity(
          opacity: fade ? 1 : 0,
          duration: Duration(milliseconds: 250),
          child: Center(
            child: specialEventDay == null
                ? SizedBox(height: 0, width: 0)
                : Text(
                    specialEventDay.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
        SizedBox(
          height: 7,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0),
          child: Container(
            height: 2.0,
            width: double.infinity,
            color: globals.darker ? Colors.white : Colors.black,
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
                          Color color = getTimetableCardColor(
                            lesson: selectedLessonList[index],
                            index: index,
                          );
                          return SafeArea(
                            child: AnimatedTimetableCard(
                              iconData: selectedLessonList[index].icon,
                              hasHomework: selectedLessonList[index]
                                          .teacherHwUid !=
                                      null &&
                                  selectedLessonList[index].teacherHwUid != "",
                              hasExam:
                                  selectedLessonList[index].examList == null
                                      ? false
                                      : (selectedLessonList[index]
                                              .examList
                                              .length !=
                                          0),
                              color: color,
                              heroAnimation: AlwaysStoppedAnimation(0),
                              lessonInfo: selectedLessonList[index],
                              onPressed: TimetableDetailTab(
                                icon: selectedLessonList[index].icon,
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
