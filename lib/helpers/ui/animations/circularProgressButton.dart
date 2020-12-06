//Based on https://github.com/khadkarajesh/nepninja
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as login;

bool squeezed = false;
double _opacity = 1.0;

//Put this functin in setState
void reset() {
  squeezed = !squeezed;
  _opacity = _opacity == 1.0 ? 0.0 : 1.0;
}

// ignore: must_be_immutable
class CircularProgressButton extends StatefulWidget {
  double width;
  double height;
  int borderRadius;
  Color backgroundColor;
  int fadeDurationInMilliSecond;
  String text;
  Color progressIndicatorColor;
  double fontSize;
  final void Function(Function reset) onTap;

  CircularProgressButton({
    this.height = 55.0,
    this.width = 200.0,
    this.borderRadius = 30,
    this.backgroundColor = Colors.lightBlueAccent,
    this.fadeDurationInMilliSecond = 700,
    this.text = "Click",
    this.progressIndicatorColor = Colors.pinkAccent,
    this.fontSize = 16.0,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() {
    return _StateAnimationButton(
      height: this.height,
      width: this.width,
      borderRadius: this.borderRadius,
      backgroundColor: this.backgroundColor,
      fadeDurationInMilliSecond: this.fadeDurationInMilliSecond,
      text: this.text,
      progressIndicatorColor: this.progressIndicatorColor,
      fontSize: this.fontSize,
      onTap: onTap,
    );
  }
}

class _StateAnimationButton extends State<CircularProgressButton> {
  static const double SQUEEZED_BORDER_RADIUS = 70.0;

  final double width;
  final double height;
  final int borderRadius;
  final Color backgroundColor;
  final int fadeDurationInMilliSecond;
  final String text;
  final Color progressIndicatorColor;
  final double fontSize;
  final void Function(Function reset) onTap;

  _StateAnimationButton({
    @required this.height,
    @required this.width,
    @required this.borderRadius,
    @required this.backgroundColor,
    @required this.fadeDurationInMilliSecond,
    @required this.text,
    @required this.progressIndicatorColor,
    @required this.fontSize,
    @required this.onTap,
  });

  @override
  void initState() {
    super.initState();
    login.resetButtonAnimation = reset;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        InkWell(
          onTap: () {
            setState(() {
              onTap(() {
                setState(() {
                  reset();
                });
              });
            });
          },
          child: AnimatedContainer(
            width: squeezed ? height : width,
            height: height,
            duration: Duration(milliseconds: fadeDurationInMilliSecond),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  squeezed ? SQUEEZED_BORDER_RADIUS : borderRadius.toDouble()),
              color: backgroundColor,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AnimatedOpacity(
                  child: Text(
                    "${this.text}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: fontSize < 18.0 ? fontSize : 18.0,
                    ),
                  ),
                  opacity: _opacity,
                  duration: Duration(seconds: 1),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            setState(() {
              onTap(() {
                setState(() {
                  reset();
                });
              });
            });
          },
          child: AnimatedContainer(
            width: squeezed ? height : width,
            height: height,
            duration: Duration(milliseconds: fadeDurationInMilliSecond),
            curve: Curves.fastOutSlowIn,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  squeezed ? SQUEEZED_BORDER_RADIUS : borderRadius.toDouble()),
            ),
            child: AnimatedOpacity(
              child: Padding(
                padding: EdgeInsets.all(1),
                child: CircularProgressIndicator(
                    backgroundColor: backgroundColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        squeezed ? progressIndicatorColor : backgroundColor)),
              ),
              opacity: _opacity == 0.0 ? 1.0 : 0.0,
              duration: Duration(milliseconds: fadeDurationInMilliSecond),
            ),
          ),
        ),
      ],
    );
  }
}
