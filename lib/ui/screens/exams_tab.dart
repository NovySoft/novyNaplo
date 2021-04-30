import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/helpers/misc/parseIntToWeekdayString.dart';
import 'package:novynaplo/helpers/ui/cardColor/examsCard.dart';
import 'package:novynaplo/ui/screens/exams_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedExamsCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;

List<Exam> allParsedExams = [];

class ExamsTab extends StatefulWidget {
  static String tag = 'exams-page';
  @override
  _ExamsTabState createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  bool _listOpen = false;
  bool _animationDone = true;
  int firstNotDone = -1;
  final GlobalKey<AnimatedListState> _animatedListkey =
      GlobalKey<AnimatedListState>(debugLabel: "examAnimList");
  final _scrollController = new ScrollController(debugLabel: "exanScrollList");
  final _dataKey = new GlobalKey(debugLabel: "examDropdownLabel");
  double _closedOfset = 0;

  @override
  void initState() {
    firstNotDone = allParsedExams.indexWhere(
      (element) {
        return DateTime.now().isBefore(element.dateOfWriting);
      },
    );
    FirebaseCrashlytics.instance.log("Shown Exams");
    super.initState();
  }

  void _handleListOpen() {
    if (!_animationDone) return;
    ScrollableState scrollableState = Scrollable.of(_dataKey.currentContext);
    ScrollPosition position = scrollableState.position;
    //FIXME: Add small icon, if there is nothing done
    if (_listOpen) {
      _scrollController.animateTo(
        _closedOfset,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
      for (int i = firstNotDone - 1; i >= 0; i--) {
        _animatedListkey.currentState.removeItem(i, (context, animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.ease,
            ),
            child: examCardBuilder(
              exam: allParsedExams[allParsedExams.length -
                  (allParsedExams.length - firstNotDone) -
                  1 -
                  i],
              context: context,
              isDone: true,
              index: allParsedExams.length -
                  (allParsedExams.length - firstNotDone) -
                  1 -
                  i,
            ),
          );
        });
      }
    } else {
      _closedOfset = position.pixels;
      for (var i = 0; i < firstNotDone; i++) {
        _animatedListkey.currentState.insertItem(i);
      }
    }
    setState(() {
      _listOpen = !_listOpen;
      _animationDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("exams")),
      ),
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: GlobalDrawer.getDrawer(ExamsTab.tag, context),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (allParsedExams.length == 0) {
      return noExam();
    } else {
      Widget currentExams;
      if (firstNotDone == -1) {
        //Minden készen van
        currentExams = SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: allDone(),
        );
      } else {
        currentExams = ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: allParsedExams.length - firstNotDone,
          itemBuilder: (context, index) {
            return examCardBuilder(
              exam: allParsedExams[firstNotDone + index],
              context: context,
              isDone: false,
              index: firstNotDone + index,
            );
          },
        );
      }
      return SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: defaultTargetPlatform == TargetPlatform.iOS
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            currentExams,
            Container(
              key: _dataKey,
              child: GestureDetector(
                onTap: () {
                  _handleListOpen();
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 15.0),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        "${getTranslatedString('doneExams')}:",
                        textAlign: defaultTargetPlatform == TargetPlatform.iOS
                            ? TextAlign.center
                            : TextAlign.left,
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
            ),
            AnimatedList(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              key: _animatedListkey,
              itemBuilder: (context, index, animation) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.ease,
                  ),
                  child: examCardBuilder(
                    exam: allParsedExams[allParsedExams.length -
                        (allParsedExams.length - firstNotDone) -
                        1 -
                        index],
                    context: context,
                    isDone: true,
                    index: allParsedExams.length -
                        (allParsedExams.length - firstNotDone) -
                        1 -
                        index,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }
  }

  Widget examCardBuilder({
    @required Exam exam,
    @required BuildContext context,
    @required bool isDone,
    @required int index,
  }) {
    DateTime examDate = exam.dateOfWriting;
    String subtitle =
        "${examDate.toDayOnlyString()} ${parseIntToWeekdayString(examDate.weekday)} (${exam.lessonNumber.intToTHEnding()} ${getTranslatedString("lesson")})";
    Color currColor = getExamsCardColor(
      index,
      exam: exam,
    );
    return SafeArea(
      child: AnimatedExamsCard(
        isDone: isDone,
        title: exam.theme,
        subTitle: subtitle,
        color: currColor,
        exam: exam,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: ExamsDetailTab(
          color: currColor,
          exam: exam,
        ),
      ),
    );
  }

  Widget noExam() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.emoticonHappyOutline,
            size: 50,
          ),
          Text(
            "${getTranslatedString("noExam")}!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget allDone() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.clipboardCheck,
            size: 50,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            getTranslatedString("allDone"),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
