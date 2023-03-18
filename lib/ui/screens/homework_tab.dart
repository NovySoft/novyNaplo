import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/parseIntToWeekdayString.dart';
import 'package:novynaplo/helpers/ui/cardColor/homeworkCard.dart';
import 'package:novynaplo/ui/screens/homework_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedHomeworkCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/helpers/ui/textColor/drawerText.dart';

//TODO: should also make a checkbox to save homework as done
List<Homework> globalHomework = [];

class HomeworkTab extends StatefulWidget {
  static String tag = 'homework';
  static String title = capitalize(getTranslatedString("hw"));

  @override
  _HomeworkTabState createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  List<Homework> currentHomework = [];
  List<Homework> toBeDoneHomework = [];
  List<Homework> alreadyDoneHomework = [];
  bool _listOpen = false;
  bool _animationDone = true;
  final GlobalKey<AnimatedListState> _animatedListkey =
      GlobalKey<AnimatedListState>(debugLabel: "homeworkAnimList");
  final _scrollController =
      new ScrollController(debugLabel: "homeworkScrollList");
  final _dataKey = new GlobalKey(debugLabel: "homeworkDropdownLabel");
  double _closedOfset = 0;

  @override
  void initState() {
    currentHomework = List.from(globalHomework);
    //Hide if it isn't needed
    currentHomework.removeWhere((element) {
      DateTime afterDue = element.dueDate;
      if (globals.howLongKeepDataForHw != -1) {
        afterDue =
            afterDue.add(Duration(days: globals.howLongKeepDataForHw.toInt()));
        return (afterDue.compareTo(DateTime.now()) < 0);
      } else {
        return false;
      }
    });
    //Parse into seperate lists
    int lastNotDone = currentHomework.lastIndexWhere((element) {
      return element.dueDate.isAfter(DateTime.now());
    });
    toBeDoneHomework = currentHomework.sublist(0, lastNotDone + 1);
    alreadyDoneHomework = currentHomework.sublist(lastNotDone + 1);
    alreadyDoneHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    FirebaseCrashlytics.instance.log("Shown Homeworks");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeworkTab.title),
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: getDrawerForeground(),
      ),
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(HomeworkTab.tag),
      body: _body(),
    );
  }

  void _handleListOpen() async {
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
      for (int i = alreadyDoneHomework.length - 1; i >= 0; i--) {
        _animatedListkey.currentState.removeItem(i, (context, animation) {
          return ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.ease,
            ),
            child: buildHomeworkCard(
              dueOver: true,
              homework: alreadyDoneHomework[i],
              index: i,
            ),
          );
        });
      }
    } else {
      _closedOfset = position.pixels;
      for (var i = 0; i < alreadyDoneHomework.length; i++) {
        _animatedListkey.currentState.insertItem(i);
      }
    }
    setState(() {
      _listOpen = !_listOpen;
      _animationDone = true;
    });
  }

  Widget _body() {
    if (currentHomework.length == 0) {
      return noHomework();
    } else {
      Widget homeworkToDo;
      if (toBeDoneHomework.length == 0) {
        homeworkToDo = SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: allDone(),
        );
      } else {
        homeworkToDo = ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: toBeDoneHomework.length,
          itemBuilder: (context, index) {
            return buildHomeworkCard(
              dueOver: false,
              homework: toBeDoneHomework[index],
              index: index,
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
            homeworkToDo,
            alreadyDoneHomework.length == 0
                ? SizedBox()
                : Container(
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
                              "${getTranslatedString('doneHw')}:",
                              textAlign:
                                  defaultTargetPlatform == TargetPlatform.iOS
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
            alreadyDoneHomework.length == 0
                ? Center(child: allDone(isDone: false))
                : AnimatedList(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    key: _animatedListkey,
                    itemBuilder: (context, index, animation) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.ease,
                        ),
                        child: buildHomeworkCard(
                          dueOver: true,
                          homework: alreadyDoneHomework[index],
                          index: index,
                        ),
                      );
                    },
                  )
          ],
        ),
      );
    }
  }

  Widget buildHomeworkCard({
    @required Homework homework,
    @required int index,
    @required bool dueOver,
  }) {
    String subTitle = "${getTranslatedString("due")}: " +
        homework.dueDate.toDayOnlyString() +
        " " +
        parseIntToWeekdayString(homework.dueDate.weekday);
    Color color = getHomeworkCardColor(
      hw: homework,
      index: index,
    );
    return SafeArea(
      child: AnimatedHomeworkCard(
        homework: homework,
        dueOver: dueOver,
        title: homework.subject.name,
        subTitle: subTitle,
        color: color,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: HomeworkDetailTab(
          color: color,
          hwInfo: homework,
        ),
      ),
    );
  }

  Widget noHomework() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.emoticonHappyOutline,
            size: 50,
          ),
          Text(
            getTranslatedString("noHw"),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget allDone({bool isDone = true}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 100,
            width: 100,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Icon(
                  MdiIcons.bagPersonalOutline,
                  size: 50,
                ),
                new Positioned(
                  left: 50,
                  top: 65,
                  child: new Icon(
                    isDone ? Icons.check : Icons.cancel_outlined,
                    size: 36.0,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            isDone
                ? getTranslatedString("allDone")
                : getTranslatedString("noDone"),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
