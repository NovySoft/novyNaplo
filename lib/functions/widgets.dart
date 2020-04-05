import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/homework_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/statistics_tab.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// A simple widget that builds different things on different platforms.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key key,
    @required this.androidBuilder,
    @required this.iosBuilder,
  })  : assert(androidBuilder != null),
        assert(iosBuilder != null),
        super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  Widget build(context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBuilder(context);
      case TargetPlatform.iOS:
        return iosBuilder(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return null;
    }
  }
}

/// A platform-agnostic card with a high elevation that reacts when tapped.
///
/// This is an example of a custom widget that an app developer might create for
/// use on both iOS and Android as part of their brand's unique design.
class PressableCard extends StatefulWidget {
  const PressableCard({
    this.onPressed,
    this.color,
    this.flattenAnimation,
    this.child,
  });

  final VoidCallback onPressed;
  final Color color;
  final Animation<double> flattenAnimation;
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
class HeroAnimatingMarksCard extends StatelessWidget {
  HeroAnimatingMarksCard(
      {this.title,
      this.subTitle,
      this.color,
      this.heroAnimation,
      this.onPressed});

  final String title;
  final String subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;

  double get playButtonSize => 100 + 50 * heroAnimation.value;

  @override
  Widget build(context) {
    double subTitleSize = 80;
    if (subTitle.length > 30) {
      subTitleSize = 100;
    }
    if (onPressed != null)
      return PressableCard(
          onPressed: null,
          color: color,
          flattenAnimation: heroAnimation,
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
                              bottom: -80 * heroAnimation.value,
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
                              padding: EdgeInsets.only(bottom: 45) *
                                  (1 - heroAnimation.value),
                              child: Container(
                                height: playButtonSize,
                                width: playButtonSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black12,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.create,
                                  size: playButtonSize,
                                  color: Colors.black38,
                                  textDirection: TextDirection.ltr,
                                ),
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
                  Positioned(
                    bottom: -80 * heroAnimation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                        height: 80,
                        color: Colors.black12,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    padding:
                        EdgeInsets.only(bottom: 45) * (1 - heroAnimation.value),
                    child: Container(
                      height: playButtonSize,
                      width: playButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black12,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.create,
                        size: playButtonSize,
                        color: Colors.black38,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ),
                ],
              )));
  }
}

// ===========================================================================
// Non-shared code below because different interfaces are shown to prompt
// for a multiple-choice answer.
//
// This is a design choice and you may want to do something different in your
// app.
// ===========================================================================
/// This uses a platform-appropriate mechanism to show users multiple choices.
///
/// On Android, it uses a dialog with radio buttons. On iOS, it uses a picker.
void showChoices(BuildContext context, List<String> choices) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      showDialog<void>(
        context: context,
        builder: (context) {
          int selectedRadio = 1;
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 12),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(choices.length, (index) {
                    return RadioListTile(
                      title: Text(
                        choices[index],
                        textDirection: TextDirection.ltr,
                      ),
                      value: index,
                      groupValue: selectedRadio,
                      // ignore: avoid_types_on_closure_parameters
                      onChanged: (int value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            ),
            actions: [
              FlatButton(
                child: Text(
                  'OK',
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              FlatButton(
                child: Text(
                  'CANCEL',
                  textDirection: TextDirection.ltr,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    case TargetPlatform.iOS:
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: CupertinoPicker(
              useMagnifier: true,
              magnification: 1.1,
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: 1),
              children: List<Widget>.generate(choices.length, (index) {
                return Center(
                  child: Text(
                    choices[index],
                    textDirection: TextDirection.ltr,
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                );
              }),
              onSelectedItemChanged: (value) {},
            ),
          );
        },
      );
      return;
    default:
      assert(false, 'Unexpected platform $defaultTargetPlatform');
  }
}

class AnimatedTitleSubtitleCard extends StatelessWidget {
  AnimatedTitleSubtitleCard({
    this.title,
    this.color,
    this.subTitle,
    this.onPressed,
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
        flattenAnimation: heroAnimation,
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

class TimetableCard extends StatelessWidget {
  TimetableCard({
    this.title,
    this.color,
    this.subTitle,
    this.onPressed,
    this.heroAnimation,
    this.hasHomework,
  });

  final String title, subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool hasHomework;

  @override
  Widget build(context) {
    if (hasHomework) {
      return PressableCard(
          onPressed: null,
          color: color,
          flattenAnimation: heroAnimation,
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
                              child: Row(children: [
                                Column(
                                    textDirection: TextDirection.ltr,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        textAlign: TextAlign.left,
                                        textDirection: TextDirection.ltr,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 25.0),
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
                          Positioned(
                            right: 8,
                            child: Icon(
                              MdiIcons.bagPersonalOutline,
                              size: 60,
                              color: Colors.black,
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
    } else {
      return PressableCard(
          onPressed: null,
          color: color,
          flattenAnimation: heroAnimation,
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
                                          color: Colors.black54,
                                          fontSize: 20.0),
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
        flattenAnimation: heroAnimation,
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
        flattenAnimation: heroAnimation,
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
                    padding: EdgeInsets.symmetric(horizontal: 12),
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

Widget getDrawer(String screen, BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
            decoration: BoxDecoration(color: Colors.grey),
            child: Center(child: new Image.asset(menuLogo, fit: BoxFit.fill))),
        ListTile(
          title: Text('Jegyek'),
          leading: Icon(Icons.create),
          onTap: () {
            if (screen == MarksTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, MarksTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Órarend'),
          leading: Icon(Icons.today),
          onTap: () {
            if (screen == TimetableTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, TimetableTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Házifeladatok'),
          leading: Icon(MdiIcons.bagPersonalOutline),
          onTap: () {
            if (screen == HomeworkTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, HomeworkTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Átlagok'),
          leading: Icon(Icons.all_inclusive),
          onTap: () {
            if (screen == AvaragesTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, AvaragesTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Feljegyzések'),
          leading: Icon(Icons.layers),
          onTap: () {
            if (screen == NoticesTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, NoticesTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Statisztika'),
          leading: Icon(MdiIcons.chartScatterPlotHexbin),
          onTap: () {
            if (screen == StatisticsTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, StatisticsTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Jegyszámoló'),
          leading: new Icon(MdiIcons.calculator),
          onTap: () {
            if (screen == CalculatorTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, CalculatorTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        ListTile(
          title: Text('Beállítások'),
          leading: Icon(Icons.settings_applications),
          onTap: () {
            if (screen == SettingsTab.tag) {
              Navigator.pop(context);
            } else {
              try {
                Navigator.pushNamed(context, SettingsTab.tag);
              } on PlatformException catch (e) {
                print(e.message);
              }
            }
          },
        ),
        SizedBox(height: 250)
      ],
    ),
  );
}
