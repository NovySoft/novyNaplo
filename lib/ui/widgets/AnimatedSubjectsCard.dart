import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';
import 'package:novynaplo/global.dart' as globals;

class AnimatedSubjectsCard extends StatelessWidget {
  AnimatedSubjectsCard(
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: globals.markCardTheme == "Dark"
                                ? Colors.grey[350]
                                : Colors.black,
                            fontSize: 21,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          subTitle,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: globals.markCardTheme == "Dark"
                                ? Colors.grey[350].withOpacity(0.9)
                                : Colors.black,
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
