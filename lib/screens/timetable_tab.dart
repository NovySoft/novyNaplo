import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/timetable_detail_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';

List<List<Lesson>> lessonsList = [];
List<DateTime> fetchedDayList = [];
var selectedLessonList = [];
int i = 0;
DateTime _selectedDate = DateTime.now();
var alma = DateTime.monday;
final CalendarWeekController _controller = CalendarWeekController();
bool fade = true;

class TimetableTab extends StatefulWidget {
  static String tag = 'timetable';
  @override
  _TimetableTabState createState() => _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  //TODO: Fetch not  yet fetched
  //TODO: Notifications payload
  @override
  Widget build(BuildContext context) {
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
    if (fetchedDayList
            .where((element) =>
                element.day == _selectedDate.day &&
                element.month == _selectedDate.month &&
                element.year == _selectedDate.year)
            .length ==
        0) {
      print("NOT FETCHED");
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
          minDate: DateTime.now().add(
            Duration(days: -365),
          ),
          maxDate: DateTime.now().add(
            Duration(days: 365),
          ),
          onDatePressed: (DateTime datetime) async {
            setState(() {
              fade = false;
            });
            await sleep(250);
            setState(() {
              _selectedDate = datetime;
              fade = true;
            });
          },
          onDateLongPressed: (DateTime datetime) async {
            setState(() {
              fade = false;
            });
            await sleep(250);
            setState(() {
              _selectedDate = datetime;
              fade = true;
            });
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
                          return SafeArea(
                            top: false,
                            bottom: false,
                            child: TimetableCard(
                              iconData: selectedLessonList[index].homework.icon,
                              hasHomework:
                                  selectedLessonList[index].homework.content !=
                                      null,
                              color: marksPage.colors[index],
                              heroAnimation: AlwaysStoppedAnimation(0),
                              lessonInfo: selectedLessonList[index],
                              onPressed: TimetableDetailTab(
                                icon: selectedLessonList[index].homework.icon,
                                color: marksPage.colors[index],
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
