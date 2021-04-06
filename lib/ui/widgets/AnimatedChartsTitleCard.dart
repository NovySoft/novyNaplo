import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/helpers/ui/textColor/statisticsCard.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';

class AnimatedChartsTitleCard extends StatelessWidget {
  AnimatedChartsTitleCard({
    this.title,
    this.color,
    this.onPressed,
    this.heroAnimation,
    this.eval,
  });

  final String title;
  final Color color;
  final Animation<double> heroAnimation;
  final Widget onPressed;
  final Evals eval;

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
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: getStatisticsCardTextColor(eval: eval),
                                  fontSize: 25.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
