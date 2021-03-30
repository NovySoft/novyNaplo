import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';

class AnimatedTitleSubtitleCard extends StatelessWidget {
  AnimatedTitleSubtitleCard({
    @required this.title,
    @required this.color,
    @required this.subTitle,
    @required this.onPressed,
    @required this.textColor,
    this.heroAnimation,
  });

  final String title, subTitle;
  final Color color;
  final Color textColor;
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
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: textColor, fontSize: 25.0),
                                  ),
                                  Text(
                                    subTitle,
                                    textAlign: TextAlign.left,
                                    textDirection: TextDirection.ltr,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: textColor.withOpacity(0.9),
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
