import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';
import 'package:novynaplo/global.dart' as globals;

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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            globals.homeworkCardTheme == "Dark"
                                                ? Colors.grey[350]
                                                : Colors.black,
                                        fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: globals.homeworkCardTheme ==
                                                "Dark"
                                            ? Colors.grey[350].withOpacity(0.9)
                                            : Colors.black54,
                                        fontSize: 20.0),
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
