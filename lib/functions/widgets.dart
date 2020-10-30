import 'package:animations/animations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/events_tab.dart';
import 'package:novynaplo/screens/exams_tab.dart';
import 'package:novynaplo/screens/homework_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/reports_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/screens/settings/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/statistics_tab.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/translations/translationProvider.dart';

class PressableCard extends StatefulWidget {
  PressableCard({
    this.onPressed,
    this.color,
    this.child,
  });

  final VoidCallback onPressed;
  final Color color;
  final Animation<double> flattenAnimation = AlwaysStoppedAnimation(0);
  final Widget child;

  @override
  State<StatefulWidget> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  bool pressed = false;
  AnimationController controller;
  Animation<double> elevationAnimation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 40),
    );
    elevationAnimation =
        controller.drive(CurveTween(curve: Curves.easeInOutCubic));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  double get flatten => 1 - widget.flattenAnimation.value;

  @override
  Widget build(context) {
    return Listener(
      onPointerDown: (details) {
        if (widget.onPressed != null) {
          controller.forward();
        }
      },
      onPointerUp: (details) {
        controller.reverse();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (widget.onPressed != null) {
            widget.onPressed();
          }
        },
        // This widget both internally drives an animation when pressed and
        // responds to an external animation to flatten the card when in a
        // hero animation. You likely want to modularize them more in your own
        // app.
        child: AnimatedBuilder(
          animation:
              Listenable.merge([elevationAnimation, widget.flattenAnimation]),
          child: widget.child,
          builder: (context, child) {
            return Transform.scale(
              // This is just a sample. You likely want to keep the math cleaner
              // in your own app.
              scale: 1 - elevationAnimation.value * 0.03,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16) *
                    flatten,
                child: PhysicalModel(
                  elevation:
                      ((1 - elevationAnimation.value) * 10 + 10) * flatten,
                  borderRadius: BorderRadius.circular(12 * flatten),
                  clipBehavior: Clip.antiAlias,
                  color: widget.color,
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A platform-agnostic card representing a song which can be in a card state,
/// a flat state or anything in between.
///
/// When it's in a card state, it's pressable.
///
/// This is an example of a custom widget that an app developer might create for
/// use on both iOS and Android as part of their brand's unique design.
class AnimatedMarksCard extends StatelessWidget {
  AnimatedMarksCard(
      {this.title,
      this.subTitle,
      this.color,
      this.onPressed,
      this.iconData,
      @required this.eval});

  final String title;
  final String subTitle;
  final Color color;
  final Widget onPressed;
  final Evals eval;
  final IconData iconData;

  double get playButtonSize => 120;

  @override
  Widget build(context) {
    IconData icon = iconData;
    if (iconData == null && eval != null) {
      icon = parseSubjectToIcon(subject: eval.subject);
    }
    double subTitleSize = 80;
    if (subTitle.length > 30) {
      subTitleSize = 100;
    }
    if (onPressed != null)
      return PressableCard(
          onPressed: null,
          color: color,
          child: SizedBox(
            height: 250,
            width: double.infinity,
            child: Container(
              color: color,
              child: OpenContainer(
                  closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  openShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1)),
                  transitionDuration: Duration(milliseconds: 550),
                  openColor: color,
                  closedColor: color,
                  closedBuilder:
                      (BuildContext context, VoidCallback openContainer) {
                    return Container(
                        color: color,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // The song title banner slides off in the hero animation.
                            Positioned(
                              bottom: 1,
                              left: 0,
                              right: 0,
                              child: Container(
                                  height: subTitleSize,
                                  color: Colors.black12,
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        title,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        subTitle,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 21,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            // The play button grows in the hero animation.
                            Padding(
                              padding: EdgeInsets.only(bottom: 70),
                              child: Icon(
                                icon,
                                size: playButtonSize,
                                color: Colors.black38,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ],
                        ));
                  },
                  openBuilder:
                      (BuildContext context, VoidCallback openContainer) {
                    return onPressed;
                  }),
            ),
          ));
    else
      return SizedBox(
          height: 250,
          width: double.infinity,
          child: Container(
              color: color,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    icon,
                    size: playButtonSize,
                    color: Colors.black38,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              )));
  }
}

class AnimatedTitleSubtitleCard extends StatelessWidget {
  AnimatedTitleSubtitleCard({
    @required this.title,
    @required this.color,
    @required this.subTitle,
    @required this.onPressed,
    this.heroAnimation,
  });

  final String title, subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            color: Colors.black12,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20.0),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

class AnimatedExamsCard extends StatelessWidget {
  AnimatedExamsCard({
    this.title,
    this.color,
    this.subTitle,
    this.onPressed,
    this.heroAnimation,
    @required this.isDone,
  });

  final String title, subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool isDone;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            color: Colors.black12,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20.0),
                                  ),
                                ]),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: Icon(
                            isDone
                                ? MdiIcons.checkDecagram
                                : MdiIcons.alarmLight,
                            size: 60,
                            color: isDone ? Colors.green[300] : Colors.red[900],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

class AnimatedHomeworkCard extends StatelessWidget {
  AnimatedHomeworkCard({
    this.title,
    this.color,
    this.subTitle,
    this.onPressed,
    this.heroAnimation,
    this.dueOver,
  });

  final String title, subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool dueOver;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            color: Colors.black12,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black54, fontSize: 20.0),
                                  ),
                                ]),
                          ),
                        ),
                        dueOver
                            ? Positioned(
                                right: 8,
                                child: Icon(
                                  MdiIcons.alarmLight,
                                  size: 60,
                                  color: Colors.red[900],
                                ),
                              )
                            : SizedBox(height: 0, width: 0),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

class TimetableCard extends StatelessWidget {
  TimetableCard(
      {this.color,
      this.onPressed,
      this.heroAnimation,
      this.hasHomework,
      this.lessonInfo,
      @required this.iconData});

  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool hasHomework;
  final IconData iconData;
  final Lesson lessonInfo;

  @override
  Widget build(context) {
    String subTitle = getTimetableSubtitle(lessonInfo);
    String title = lessonInfo.name;
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 120,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 120,
                            color: color,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(children: [
                              Column(
                                  textDirection: TextDirection.ltr,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 25.0),
                                    ),
                                    Text(
                                      subTitle,
                                      textAlign: TextAlign.left,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20.0),
                                    ),
                                  ]),
                            ]),
                          ),
                        ),
                        hasHomework
                            ? Positioned(
                                right: 8,
                                child: Icon(
                                  MdiIcons.bagPersonalOutline,
                                  size: 60,
                                  color: Colors.black,
                                ),
                              )
                            : SizedBox(height: 0, width: 0),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

class AnimatedChartsCard extends StatelessWidget {
  AnimatedChartsCard({
    this.title,
    this.color,
    this.onPressed,
    this.heroAnimation,
  });

  final String title;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100,
                            color: Colors.black12,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                textDirection: TextDirection.ltr,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 25.0),
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

class HeroAnimatingSubjectsCard extends StatelessWidget {
  HeroAnimatingSubjectsCard(
      {this.subTitle,
      this.title,
      this.color,
      this.heroAnimation,
      this.onPressed});

  final String subTitle;
  final String title;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;

  double get playButtonSize => 100 + 50 * heroAnimation.value;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 250,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return Container(
                    height: 80,
                    color: color,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          subTitle,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}

//TODO Add option to remove items from drawer or reorder cards
Widget getDrawer(String screen, BuildContext context) {
  return Drawer(
    child: CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          stretch: true,
          title: new Container(),
          leading: new Container(),
          backgroundColor: Colors.grey,
          expandedHeight: 150.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(menuLogo, fit: BoxFit.contain),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              switch (index) {
                case 0:
                  return SizedBox(
                    height: 5,
                  );
                  break;
                case 1:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("marks"))),
                    leading: Icon(Icons.create),
                    onTap: () {
                      if (screen == MarksTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, MarksTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 2:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("reports"))),
                    leading: Icon(MdiIcons.fileChart),
                    onTap: () {
                      if (screen == ReportsTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, ReportsTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 3:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("timetable"))),
                    leading: Icon(Icons.today),
                    onTap: () {
                      if (screen == TimetableTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, TimetableTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 4:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("exams"))),
                    leading: Icon(MdiIcons.clipboardText),
                    onTap: () {
                      if (screen == ExamsTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, ExamsTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 5:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("hw"))),
                    leading: Icon(MdiIcons.bagPersonalOutline),
                    onTap: () {
                      if (screen == HomeworkTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, HomeworkTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 6:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("notices"))),
                    leading: Icon(Icons.layers),
                    onTap: () {
                      if (screen == NoticesTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, NoticesTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 7:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("events"))),
                    leading: Icon(MdiIcons.pin),
                    onTap: () {
                      if (screen == EventsTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, EventsTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 8:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("statistics"))),
                    leading: Icon(MdiIcons.chartScatterPlotHexbin),
                    onTap: () {
                      if (screen == StatisticsTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, StatisticsTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 9:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("markCalc"))),
                    leading: new Icon(MdiIcons.calculator),
                    onTap: () {
                      if (screen == CalculatorTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, CalculatorTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
                      }
                    },
                  );
                  break;
                case 10:
                  return ListTile(
                    title: Text(capitalize(getTranslatedString("settings"))),
                    leading: Icon(Icons.settings_applications),
                    onTap: () {
                      if (screen == SettingsTab.tag) {
                        Navigator.pop(context);
                      } else {
                        try {
                          Navigator.pushNamed(context, SettingsTab.tag);
                        } catch (e, s) {
                          FirebaseCrashlytics.instance.recordError(
                            e,
                            s,
                            reason: 'getDrawer',
                            printDetails: true,
                          );
                          print(e.message);
                        }
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
  );
}

class AnimatedLeadingTrailingCard extends StatelessWidget {
  AnimatedLeadingTrailingCard({
    @required this.leading,
    @required this.color,
    @required this.trailing,
    @required this.onPressed,
  });

  final Color color;
  final Widget onPressed, leading, trailing;

  @override
  Widget build(context) {
    return PressableCard(
        onPressed: null,
        color: color,
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Container(
            color: color,
            child: OpenContainer(
                closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1)),
                transitionDuration: Duration(milliseconds: 550),
                openColor: color,
                closedColor: color,
                closedBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        Positioned(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: leading,
                          ),
                        ),
                        Positioned(
                          right: 8,
                          child: trailing,
                        ),
                      ],
                    ),
                  );
                },
                openBuilder:
                    (BuildContext context, VoidCallback openContainer) {
                  return onPressed;
                }),
          ),
        ));
  }
}
