import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/getTimetableSubtitle.dart';
import 'package:novynaplo/helpers/ui/textColor/timetableCard.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';
import 'package:novynaplo/global.dart' as globals;

class AnimatedTimetableCard extends StatelessWidget {
  AnimatedTimetableCard(
      {this.color,
      this.onPressed,
      this.heroAnimation,
      this.hasHomework = false,
      this.hasExam = false,
      this.lessonInfo,
      @required this.iconData});

  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool hasHomework;
  final bool hasExam;
  final IconData iconData;
  final Lesson lessonInfo;

  @override
  Widget build(context) {
    String subTitle = getTimetableSubtitle(lessonInfo);
    Color txtColor = getTimetableCardTextColor(lesson: lessonInfo);
    String title = lessonInfo.subject.name;
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
                                    lessonInfo.state.name == "Elmaradt" ||
                                            lessonInfo.type.name == "UresOra"
                                        ? getTranslatedString("cancelled") +
                                            " " +
                                            capitalize(title)
                                        : capitalize(title),
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: txtColor,
                                      fontSize: 25.0,
                                      decoration: lessonInfo.state.name ==
                                                  "Elmaradt" ||
                                              lessonInfo.type.name == "UresOra"
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationThickness: 2.85,
                                    ),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: txtColor.withOpacity(0.9),
                                      fontSize: 20.0,
                                      decoration: lessonInfo.state.name ==
                                                  "Elmaradt" ||
                                              lessonInfo.type.name == "UresOra"
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationThickness: 2.85,
                                    ),
                                  ),
                                ]),
                          ]),
                        ),
                      ),
                      (hasHomework != hasExam) && !(hasHomework && hasExam)
                          ? Positioned(
                              right: 8,
                              child: Icon(
                                hasHomework
                                    ? MdiIcons.bagPersonalOutline
                                    : MdiIcons.clipboardText,
                                size: 60,
                                color: globals.timetableCardTheme == "Dark"
                                    ? Colors.grey[350]
                                    : Colors.black,
                              ),
                            )
                          : SizedBox(height: 0, width: 0),
                      (hasHomework && hasExam)
                          ? Positioned(
                              right: 8,
                              child: Row(
                                children: [
                                  Icon(
                                    MdiIcons.bagPersonalOutline,
                                    size: 30,
                                    color: globals.timetableCardTheme == "Dark"
                                        ? Colors.grey[350]
                                        : Colors.black,
                                  ),
                                  Icon(
                                    MdiIcons.clipboardText,
                                    size: 30,
                                    color: globals.timetableCardTheme == "Dark"
                                        ? Colors.grey[350]
                                        : Colors.black,
                                  ),
                                ],
                              ),
                            )
                          : SizedBox(height: 0, width: 0),
                    ],
                  ),
                );
              },
              openBuilder: (BuildContext context, VoidCallback openContainer) {
                return onPressed;
              }),
        ),
      ),
    );
  }
}
