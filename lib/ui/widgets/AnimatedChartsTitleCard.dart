import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';

class AnimatedChartsTitleCard extends StatelessWidget {
  AnimatedChartsTitleCard({
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