import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/TitleSubtitleColumn.dart';

class SchoolDetailsDropdown extends StatefulWidget {
  const SchoolDetailsDropdown({
    @required this.schoolDetails,
  });
  final Institution schoolDetails;

  @override
  _SchoolDetailsDropdownState createState() => _SchoolDetailsDropdownState();
}

class _SchoolDetailsDropdownState extends State<SchoolDetailsDropdown> {
  bool _isAnimationDone = true;

  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>(debugLabel: "SchoolDetailsListKey");
  bool _listOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (!_isAnimationDone) return;
            _isAnimationDone = false;
            if (_listOpen) {
              for (int i = 6 - 1; i >= 0; i--) {
                _animatedListKey.currentState.removeItem(i,
                    (context, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.ease,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: SchoolDetails(
                        index: i,
                        schoolDetails: widget.schoolDetails,
                      ),
                    ),
                  );
                });
                await delay(50);
              }
            } else {
              for (var i = 0; i < 6; i++) {
                _animatedListKey.currentState.insertItem(i);
                await delay(50);
              }
            }
            setState(() {
              _isAnimationDone = true;
              _listOpen = !_listOpen;
            });
          },
          child: Container(
            height: 45,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  getTranslatedString("schoolDetails") + ": ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 150),
                  firstChild: const Icon(
                    Icons.keyboard_arrow_up,
                    size: 30,
                  ),
                  secondChild: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                  crossFadeState: _listOpen
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        AnimatedList(
          key: _animatedListKey,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0, -0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              )),
              child: FadeTransition(
                opacity: animation,
                child: SchoolDetails(
                  index: index,
                  schoolDetails: widget.schoolDetails,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class SchoolDetails extends StatelessWidget {
  const SchoolDetails({
    @required this.index,
    @required this.schoolDetails,
  });
  final Institution schoolDetails;
  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("name+uid"),
              subtitle: schoolDetails.name + " #" + schoolDetails.uid,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 1:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("shortname"),
              subtitle: schoolDetails.shortName,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 2:
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getTranslatedString("modules") + ":",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: schoolDetails.systemModules.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Row(children: [
                                SizedBox(width: 10),
                                Text(
                                  capitalize(
                                        schoolDetails.systemModules[index].type,
                                      ) +
                                      ": ",
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  schoolDetails.systemModules[index].active
                                      ? AntDesign.check
                                      : Entypo.cross,
                                  size: 16,
                                  color:
                                      schoolDetails.systemModules[index].active
                                          ? Colors.green
                                          : Colors.red,
                                ),
                              ]),
                              if (schoolDetails.systemModules.length - 1 !=
                                  index)
                                SizedBox(height: 3),
                            ],
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 3:
        return Column(
          children: [
            Row(
              children: [
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        getTranslatedString("schCustom") + ":",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getTranslatedString("studentHomework") + ": ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            schoolDetails.customizationOptions
                                    .isStudentHomeworkEnabled
                                ? AntDesign.check
                                : Entypo.cross,
                            size: 16,
                            color: schoolDetails.customizationOptions
                                    .isStudentHomeworkEnabled
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getTranslatedString("lessonTheme") + ": ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            schoolDetails
                                    .customizationOptions.canViewThemeOfLesson
                                ? AntDesign.check
                                : Entypo.cross,
                            size: 16,
                            color: schoolDetails
                                    .customizationOptions.canViewThemeOfLesson
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getTranslatedString("classAv") + ": ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Icon(
                            schoolDetails.customizationOptions.canViewClassAV
                                ? AntDesign.check
                                : Entypo.cross,
                            size: 16,
                            color: schoolDetails
                                    .customizationOptions.canViewClassAV
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            getTranslatedString("evalDelay") + ": ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          schoolDetails.customizationOptions.evalShowDelay == 0
                              ? Icon(
                                  Entypo.cross,
                                  size: 16,
                                  color: Colors.red,
                                )
                              : Text(
                                  schoolDetails
                                      .customizationOptions.evalShowDelay
                                      .toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      default:
        return SizedBox();
    }
  }
}
