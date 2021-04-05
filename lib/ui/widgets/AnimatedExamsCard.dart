import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/helpers/ui/textColor/examsCard.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';
import 'package:novynaplo/global.dart' as globals;

class AnimatedExamsCard extends StatelessWidget {
  AnimatedExamsCard({
    this.title,
    this.color,
    this.subTitle,
    this.onPressed,
    this.heroAnimation,
    this.exam,
    @required this.isDone,
  });

  final String title, subTitle;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final bool isDone;
  final Exam exam;

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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: getExamsCardTextColor(
                                          exam: exam,
                                        ),
                                        fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: getExamsCardTextColor(
                                          exam: exam,
                                        ).withOpacity(0.9),
                                        fontSize: 20.0),
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
