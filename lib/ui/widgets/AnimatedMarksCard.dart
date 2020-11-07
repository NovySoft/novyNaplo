import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';

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
