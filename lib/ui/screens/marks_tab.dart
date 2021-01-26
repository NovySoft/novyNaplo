import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart';
import 'package:novynaplo/helpers/ui/colorHelper.dart';
import 'package:novynaplo/helpers/ui/getMarkCardSubtitle.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/marks_detail_tab.dart';
import 'package:novynaplo/ui/widgets/AnimatedMarksCard.dart';
import 'package:novynaplo/ui/widgets/AnimatedSubjectsCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'dart:async';
import 'package:novynaplo/i18n/translationProvider.dart';

List<Evals> allParsedByDate = [];
List<List<Evals>> allParsedBySubject = [];
int selectedIndex = 0;
bool differenSubject = false;
final List<Tab> markTabs = <Tab>[
  Tab(text: getTranslatedString("byDate"), icon: Icon(Icons.calendar_today)),
  Tab(text: getTranslatedString("bySubject"), icon: Icon(Icons.view_list)),
];
String label, labelBefore;
TabController _tabController;
List<dynamic> colors;

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static String title = capitalize(getTranslatedString("marks"));

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  MarksTabState createState() => MarksTabState();
}

class MarksTabState extends State<MarksTab>
    with SingleTickerProviderStateMixin {
  GlobalKey<RefreshIndicatorState> androidRefreshKey =
      GlobalKey<RefreshIndicatorState>(debugLabel: "1");
  GlobalKey<RefreshIndicatorState> androidRefreshKeyTwo =
      GlobalKey<RefreshIndicatorState>(debugLabel: "2");

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Marks");
    //setup tabcontroller
    _tabController = new TabController(vsync: this, length: 2);
    //Fetching data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!globals.didFetch) {
        globals.didFetch = true;
        androidRefreshKey.currentState?.show();
      }
    });
    //Handle loaded state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await delay(500);
      globals.isLoaded = true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setData() {
    allParsedByDate = allParsedByDate;
    colors = getRandomColors(allParsedByDate.length);
    allParsedBySubject = sortByDateAndSubject(allParsedByDate);
  }

  Future<void> _refreshData() async {
    FirebaseAnalytics().logEvent(name: "RefreshData");
    FirebaseCrashlytics.instance.log("RefreshData");
    if (!(await NetworkHelper.isNetworkAvailable())) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslatedString("status")),
            content: Text(getTranslatedString("noNet")),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }
    await NotificationHelper.show(
      -111,
      getTranslatedString("gettingData"),
      '${getTranslatedString("currGetData")}...',
      platformChannelSpecificsGetNotif,
    );
    List<Student> allUsers = await DatabaseHelper.getAllUsers();
    for (var currentUser in allUsers) {
      TokenResponse status = await RequestHandler.login(currentUser);
      if (status.status == "OK") {
        if (currentUser.current) {
          globals.currentUser.token = status.userinfo.token;
          globals.currentUser.tokenDate = status.userinfo.tokenDate;
        }
        await RequestHandler.getEverything(
          status.userinfo,
          setData: currentUser.current,
        );
        setState(() {
          _setData();
        });
      } else {
        //Fixme show toasts on ALL errors;
        print(status);
      }
    }

    await NotificationHelper.cancel(-111);
  }

  Widget _dateListBuilder(BuildContext context, int index) {
    if (index >= allParsedByDate.length) {
      return SizedBox(
        height: 150,
      );
    }
    Color color = getMarkCardColor(
      eval: allParsedByDate[index],
      index: index,
    );
    return SafeArea(
      child: AnimatedMarksCard(
        eval: allParsedByDate[index],
        iconData: allParsedByDate[index].icon,
        subTitle: getMarkCardSubtitle(
          eval: allParsedByDate[index],
        ), //capitalize(allParsedByDate[index].theme),
        title: capitalize(allParsedByDate[index].subject.name +
            " " +
            allParsedByDate[index].textValue),
        color: color,
        onPressed: MarksDetailTab(
          eval: allParsedByDate[index],
          color: color,
        ),
      ),
    );
  }

  Widget _subjectListBuilder(BuildContext context, int listIndex) {
    if (listIndex >= allParsedBySubject.length) {
      return SizedBox(
        height: 150,
      );
    }
    return ListView.builder(
      itemCount: allParsedBySubject[listIndex].length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        //return Text(allParsedBySubject[listIndex][index].subject);
        int indexSum = 0;
        for (int i = 0; i <= listIndex - 1; i++) {
          indexSum += allParsedBySubject[i].length;
        }
        Color color = getMarkCardColor(
          eval: allParsedBySubject[listIndex][index],
          index: indexSum + index,
        );
        if (index == 0) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: defaultTargetPlatform == TargetPlatform.iOS
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  capitalize(
                          allParsedBySubject[listIndex][index].subject.name) +
                      ":",
                  textAlign: defaultTargetPlatform == TargetPlatform.iOS
                      ? TextAlign.center
                      : TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 106,
                child: SafeArea(
                  child: AnimatedSubjectsCard(
                    subTitle: getMarkCardSubtitle(
                      eval: allParsedBySubject[listIndex][index],
                    ),
                    title: capitalize(
                      allParsedBySubject[listIndex][index].textValue,
                    ),
                    color: color,
                    heroAnimation: AlwaysStoppedAnimation(0),
                    onPressed: MarksDetailTab(
                      eval: allParsedBySubject[listIndex][index],
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 106,
          child: SafeArea(
            child: AnimatedSubjectsCard(
              subTitle: getMarkCardSubtitle(
                eval: allParsedBySubject[listIndex][index],
              ),
              title: capitalize(
                allParsedBySubject[listIndex][index].textValue,
              ),
              color: color,
              heroAnimation: AlwaysStoppedAnimation(0),
              onPressed: MarksDetailTab(
                eval: allParsedBySubject[listIndex][index],
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GlobalDrawer.getDrawer(MarksTab.tag, context),
      appBar: AppBar(
        title: Text(MarksTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: markTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: markTabs.map((Tab tab) {
            if (tab.text == getTranslatedString("byDate")) {
              return RefreshIndicator(
                key: androidRefreshKey,
                onRefresh: () async {
                  await _refreshData();
                },
                child: allParsedByDate.length == 0
                    ? noMarks()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allParsedByDate.length +
                            (globals.adsEnabled ? 1 : 0),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: _dateListBuilder,
                      ),
              );
            } else {
              return RefreshIndicator(
                key: androidRefreshKeyTwo,
                onRefresh: () async {
                  await _refreshData();
                },
                child: allParsedByDate.length == 0
                    ? noMarks()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allParsedBySubject.length +
                            (globals.adsEnabled ? 1 : 0),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: _subjectListBuilder,
                      ),
              );
            }
          }).toList()),
    );
  }

  Widget noMarks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.emoticonSadOutline,
            size: 50,
          ),
          Text(
            "${getTranslatedString("possibleNoMarks")}!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
