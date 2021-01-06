import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/ui/widgets/PressableCard.dart';

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
