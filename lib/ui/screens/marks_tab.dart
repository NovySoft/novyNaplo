import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/certValidation.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/tokenResponse.dart';
import 'package:novynaplo/helpers/logicAndMath/getMarksWithChanges.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notification/models.dart';
import 'package:novynaplo/helpers/notification/notificationDispatcher.dart';
import 'package:novynaplo/helpers/notification/notificationHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/helpers/ui/getMarkCardSubtitle.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as login;
import 'package:novynaplo/ui/screens/marks_detail_tab.dart';
import 'package:novynaplo/ui/widgets/AnimatedMarksCard.dart';
import 'package:novynaplo/ui/widgets/AnimatedSubjectsCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'dart:async';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/main.dart' as main;
import 'package:novynaplo/helpers/ui/cardColor/markCard.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import '../../data/models/average.dart';

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
  final bool isFirstNavigator;

  const MarksTab(
    this.isFirstNavigator,
  );

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
      if (!globals.didFetch || !globals.currentUser.fetched) {
        globals.didFetch = true;
        androidRefreshKey.currentState?.show();
      }
      if (main.isNew) {
        //!Handle new users here
        main.isNew = false;
      }
    });
    super.initState();
    //Handle loaded state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await delay(500);
      globals.isNavigatorLoaded = true;
      if (globals.continueSession != null && globals.currentUser.fetched) {
        if (globals.continueSession != MarksTab.tag)
          Navigator.of(context).pushNamed(globals.continueSession);
      }
      globals.continueSession = null;
    });
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
    FirebaseAnalytics.instance.logEvent(name: "RefreshData");
    FirebaseCrashlytics.instance.log("RefreshData");
    if (!(await NetworkHelper.isNetworkAvailable())) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: globals.darker ? 0 : 24,
            title: Text(getTranslatedString("status")),
            content: Text(getTranslatedString("noNet")),
            actions: <Widget>[
              TextButton(
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
    globals.allUsers = await DatabaseHelper.getAllUsers();
    trustedCerts = await DatabaseHelper.getTrustedCerts();
    if (globals.allUsers.length == 1 && globals.allUsers[0].current == false) {
      await DatabaseHelper.setCurrentUser(globals.allUsers[0].userId);
      globals.allUsers[0].current = true;
      globals.currentUser.current = true;
    }
    for (var currentUser in globals.allUsers) {
      TokenResponse status = await RequestHandler.login(currentUser);
      if (status.status == "OK") {
        if (currentUser.current) {
          globals.currentUser.token = status.userinfo.token;
          globals.currentUser.tokenDate = status.userinfo.tokenDate;
        }
        bool isErrored = await RequestHandler.getEverything(
          status.userinfo,
          setData: currentUser.current,
        );
        if (isErrored) {
          ErrorToast.showErrorToastLong(
            context,
            getTranslatedString("errWhileFetch") +
                "\n" +
                getTranslatedString("incorrectData"),
          );
        }
        if (!currentUser.fetched || !globals.currentUser.fetched) {
          currentUser.fetched = true;
          if (currentUser.current) {
            globals.currentUser.fetched = true;
          }
          DatabaseHelper.setFetched(
            currentUser,
            true,
          );
        }
        getMarksWithChanges(
          stats.allParsedSubjectsWithoutZeros,
          globals.currentUser,
        );
        if (this.mounted) {
          setState(() {
            _setData();
          });
        }
      } else if (status.status == "invalid_username_or_password") {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                elevation: globals.darker ? 0 : 24,
                title: Text(getTranslatedString("err")),
                content: Text(getTranslatedString("invPassOrKretaDownWarning")),
                actions: [
                  TextButton(
                    child: Text(getTranslatedString("cancel")),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      getTranslatedString("changePass"),
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => login.LoginPage(
                            userDetails: currentUser,
                            isEditing: true,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            });
        break;
      } else {
        print("Error while getting tokens: ${status.status}");
        ErrorToast.showErrorToastLong(
          context,
          getTranslatedString("errToken") + ":\n" + status.status,
        );
      }
    }

    await NotificationHelper.cancel(-111);
    if (globals.notifications) {
      await NotificationDispatcher.dispatchNotifications();
    } else {
      //Clear the notification list if we are not sending it -> otherwise the next time it will send them.
      NotificationDispatcher.toBeDispatchedNotifications =
          ToBeDispatchedNotifications();
    }
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
        int indexSum = 0;
        for (int i = 0; i <= listIndex - 1; i++) {
          indexSum += allParsedBySubject[i].length;
        }
        Color color = getMarkCardColor(
          eval: allParsedBySubject[listIndex][index],
          index: indexSum + index,
        );
        if (index == 0) {
          Average currentAv = stats.allSubjectsAv.firstWhere(
            (element) =>
                element.subjectUid ==
                allParsedBySubject[listIndex][index].subject.uid,
            orElse: () => null,
          );
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: defaultTargetPlatform == TargetPlatform.iOS
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      capitalize(allParsedBySubject[listIndex][index]
                              .subject
                              .name) +
                          ":",
                      textAlign: defaultTargetPlatform == TargetPlatform.iOS
                          ? TextAlign.center
                          : TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      currentAv.value.toStringAsFixed(3),
                      textAlign: TextAlign.start,
                      style: new TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 106,
                child: SafeArea(
                  child: AnimatedSubjectsCard(
                    eval: allParsedBySubject[listIndex][index],
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
              eval: allParsedBySubject[listIndex][index],
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
    Widget mainWidget = Scaffold(
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(MarksTab.tag),
      appBar: AppBar(
        backgroundColor: globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: globals.appBarTextColoredByUser ? globals.currentUser.color : null,
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
                        itemCount: allParsedByDate.length,
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
                        itemCount: allParsedBySubject.length,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: _subjectListBuilder,
                      ),
              );
            }
          }).toList()),
    );
    return widget.isFirstNavigator
        ? WillPopScope(
            onWillPop: () async {
              FirebaseCrashlytics.instance.log("Minimize app");
              return true;
            },
            child: mainWidget,
          )
        : mainWidget;
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
