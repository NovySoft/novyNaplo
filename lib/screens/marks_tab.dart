import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart';
import 'package:novynaplo/screens/marks_detail_tab.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'dart:async';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Evals> allParsedByDate, allParsedBySubject;
int selectedIndex = 0;
bool differenSubject = false;
String subjectBefore = "";
final List<Tab> markTabs = <Tab>[
  Tab(text: 'Dátum szerint', icon: Icon(Icons.calendar_today)),
  Tab(text: 'Tantárgy szerint', icon: Icon(Icons.view_list)),
];
String label, labelBefore;
TabController _tabController;
List<dynamic> colors;

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static const title = 'Jegyek';
  static const androidIcon = Icon(Icons.music_note);

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  MarksTabState createState() => MarksTabState();
}

class MarksTabState extends State<MarksTab>
    with SingleTickerProviderStateMixin {
  int itemsLength = globals.markCount;
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();
  final _androidRefreshKeyTwo = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    _tabController = new TabController(vsync: this, length: 2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if ((globals.backgroundFetch || globals.offlineModeDb) &&
          !globals.didFetch) {
        globals.didFetch = true;
        _androidRefreshKey.currentState?.show();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    adBanner.dispose();
    super.dispose();
  }

  Future<void> _setData() async {
    colors = getRandomColors(globals.markCount);
    allParsedByDate = await parseAllByDate(globals.dJson);
    allParsedBySubject = parseAllBySubject(globals.dJson);
  }

  Future<void> _refreshData() async {
    FirebaseAnalytics().logEvent(name: "RefreshData");
    Crashlytics.instance.log("RefreshData");
    await notifications.flutterLocalNotificationsPlugin.show(
      -111,
      'Adatok lekérése',
      'Éppen zajlik az adatok lekérése...',
      platformChannelSpecificsGetNotif,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //TODO fix this
    //!It only works when i put his ting here
    var decryptedPass, decryptedUser, decryptedCode, status;
    for (var i = 0; i < 2; i++) {
      final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
      var passKey = encrypt.Key.fromUtf8(config.passKey);
      var codeKey = encrypt.Key.fromUtf8(config.codeKey);
      var userKey = encrypt.Key.fromUtf8(config.userKey);
      final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
      final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
      final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
      decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      status = await NetworkHelper()
          .getToken(decryptedCode, decryptedUser, decryptedPass);
    }
    if (status == "OK") {
      await NetworkHelper().getStudentInfo(globals.token, decryptedCode);
      await _setData();
      setState(() {
        colors = colors;
        allParsedByDate = allParsedByDate;
        allParsedBySubject = allParsedBySubject;
      });
    } else {
      print(status);
    }
    await notifications.flutterLocalNotificationsPlugin.cancel(-111);
  }

  Widget _dateListBuilder(BuildContext context, int index) {
    String subtitle = "undefined";
    if (globals.markCardSubtitle == "Téma") {
      if (allParsedByDate[index].theme != null &&
          allParsedByDate[index].theme != "")
        subtitle = capitalize(allParsedByDate[index].theme);
      else
        subtitle = "Ismeretlen";
    } else if (globals.markCardSubtitle == "Tanár") {
      subtitle = allParsedByDate[index].teacher;
    } else if (globals.markCardSubtitle == "Súly") {
      subtitle = allParsedByDate[index].weight;
    } else if (globals.markCardSubtitle == "Pontos Dátum") {
      subtitle = allParsedByDate[index].createDateString;
    } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
      String year = allParsedByDate[index].createDate.year.toString();
      String month = allParsedByDate[index].createDate.month.toString();
      String day = allParsedByDate[index].createDate.day.toString();
      String hour = allParsedByDate[index].createDate.hour.toString();
      String minutes = allParsedByDate[index].createDate.minute.toString();
      String seconds = allParsedByDate[index].createDate.second.toString();
      subtitle = "$year-$month-$day $hour:$minutes:$seconds";
    }
    if (subtitle.length >= 38) {
      subtitle = subtitle.substring(0, 35);
      subtitle += "...";
    }
    if (index >= itemsLength) return null;
    var color;
    if (globals.markCardTheme == "Véletlenszerű") {
      color = colors[index].shade400;
    } else if (globals.markCardTheme == "Értékelés nagysága") {
      if (allParsedByDate[index].form == "Percent") {
        if (allParsedByDate[index].numberValue >= 90) {
          color = Colors.green;
        } else if (allParsedByDate[index].numberValue >= 75) {
          color = Colors.lightGreen;
        } else if (allParsedByDate[index].numberValue >= 60) {
          color = Colors.yellow[800];
        } else if (allParsedByDate[index].numberValue >= 40) {
          color = Colors.deepOrange;
        } else {
          color = Colors.red[900];
        }
      } else {
        switch (allParsedByDate[index].numberValue) {
          case 5:
            color = Colors.green;
            break;
          case 4:
            color = Colors.lightGreen;
            break;
          case 3:
            color = Colors.yellow[800];
            break;
          case 2:
            color = Colors.deepOrange;
            break;
          case 1:
            color = Colors.red[900];
            break;
          default:
            color = Colors.purple;
            break;
        }
      }
    } else if (globals.markCardTheme == "Egyszínű") {
      color = ThemeHelper().stringToColor(globals.markCardConstColor);
    } else if (globals.markCardTheme == "Színátmenetes") {
      color = ThemeHelper().myGradientList[
          (ThemeHelper().myGradientList.length - index - 1).abs()];
    } else {
      color = Colors.red;
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
          tag: index,
          child: HeroAnimatingMarksCard(
            eval: allParsedByDate[index],
            iconData: allParsedByDate[index].icon,
            subTitle: subtitle, //capitalize(allParsedByDate[index].theme),
            title: capitalize(allParsedByDate[index].subject +
                " " +
                allParsedByDate[index].value),
            color: color,
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: MarksDetailTab(
              //TODO refactor this shit
              eval: allParsedByDate[index],
              mode: allParsedByDate[index].mode,
              theme: allParsedByDate[index].theme,
              weight: allParsedByDate[index].weight,
              date: allParsedByDate[index].dateString,
              createDate: allParsedByDate[index].createDateString,
              teacher: allParsedByDate[index].teacher,
              subject: allParsedByDate[index].subject,
              numberValue: allParsedByDate[index].numberValue,
              value: allParsedByDate[index].value,
              formName: allParsedByDate[index].formName,
              form: allParsedByDate[index].form,
              id: index,
              name: capitalize(allParsedByDate[index].subject +
                  " " +
                  allParsedByDate[index].value),
              color: color,
            ),
          )),
    );
  }

  Widget _subjectListBuilder(BuildContext context, int index) {
    String subtitle = "undefined";
    if (globals.markCardSubtitle == "Téma") {
      if (allParsedBySubject[index].theme != null &&
          allParsedBySubject[index].theme != "")
        subtitle = capitalize(allParsedBySubject[index].theme);
      else
        subtitle = "Ismeretlen";
    } else if (globals.markCardSubtitle == "Tanár") {
      subtitle = allParsedBySubject[index].teacher;
    } else if (globals.markCardSubtitle == "Súly") {
      subtitle = allParsedBySubject[index].weight;
    } else if (globals.markCardSubtitle == "Pontos Dátum") {
      subtitle = allParsedBySubject[index].createDateString;
    } else if (globals.markCardSubtitle == "Egyszerűsített Dátum") {
      String year = allParsedBySubject[index].createDate.year.toString();
      String month = allParsedBySubject[index].createDate.month.toString();
      String day = allParsedBySubject[index].createDate.day.toString();
      String hour = allParsedBySubject[index].createDate.hour.toString();
      String minutes = allParsedBySubject[index].createDate.minute.toString();
      String seconds = allParsedBySubject[index].createDate.second.toString();
      subtitle = "$year-$month-$day $hour:$minutes:$seconds";
    }
    if (subtitle == "" || subtitle == null) {
      subtitle = "Ismeretlen";
    }
    if (subtitle.length >= 30) {
      subtitle = subtitle.substring(0, 27);
      subtitle += "...";
    }
    if (index >= itemsLength) return null;
    var color;
    if (globals.markCardTheme == "Véletlenszerű") {
      color = colors[index].shade400;
    } else if (globals.markCardTheme == "Értékelés nagysága") {
      if (allParsedBySubject[index].form == "Percent") {
        if (allParsedBySubject[index].numberValue >= 90) {
          color = Colors.green;
        } else if (allParsedBySubject[index].numberValue >= 75) {
          color = Colors.lightGreen;
        } else if (allParsedBySubject[index].numberValue >= 60) {
          color = Colors.yellow[800];
        } else if (allParsedBySubject[index].numberValue >= 40) {
          color = Colors.deepOrange;
        } else {
          color = Colors.red[900];
        }
      } else {
        switch (allParsedBySubject[index].numberValue) {
          case 5:
            color = Colors.green;
            break;
          case 4:
            color = Colors.lightGreen;
            break;
          case 3:
            color = Colors.yellow[800];
            break;
          case 2:
            color = Colors.deepOrange;
            break;
          case 1:
            color = Colors.red[900];
            break;
          default:
            color = Colors.purple;
            break;
        }
      }
    } else if (globals.markCardTheme == "Egyszínű") {
      color = ThemeHelper().stringToColor(globals.markCardConstColor);
    } else if (globals.markCardTheme == "Színátmenetes") {
      color = ThemeHelper().myGradientList[
          (ThemeHelper().myGradientList.length - index - 1).abs()];
    } else {
      color = Colors.red;
    }
    if (subjectBefore != allParsedBySubject[index].subject) {
      subjectBefore = allParsedBySubject[index].subject;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        return SizedBox(
          width: double.infinity,
          height: 135,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  capitalize(allParsedBySubject[index].subject) + ":",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Hero(
                      tag: index,
                      child: HeroAnimatingSubjectsCard(
                        subTitle: subtitle,
                        title: capitalize(allParsedBySubject[index].subject) +
                            " " +
                            allParsedBySubject[index].value,
                        color: color,
                        heroAnimation: AlwaysStoppedAnimation(0),
                        onPressed: MarksDetailTab(
                          eval: allParsedBySubject[index],
                          mode: allParsedBySubject[index].mode,
                          theme: allParsedBySubject[index].theme,
                          weight: allParsedBySubject[index].weight,
                          date: allParsedBySubject[index].dateString,
                          createDate:
                              allParsedBySubject[index].createDateString,
                          teacher: allParsedBySubject[index].teacher,
                          subject: allParsedBySubject[index].subject,
                          numberValue: allParsedBySubject[index].numberValue,
                          value: allParsedBySubject[index].value,
                          formName: allParsedBySubject[index].formName,
                          form: allParsedBySubject[index].form,
                          id: index,
                          name: capitalize(allParsedBySubject[index].subject) +
                              " " +
                              allParsedBySubject[index].value,
                          color: color,
                        ),
                      )),
                ),
              ),
            ],
          ),
        );
      } else {
        return SizedBox(
          width: double.infinity,
          height: 135,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  capitalize(allParsedBySubject[index].subject) + ":",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              Expanded(
                flex: 10,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Hero(
                    tag: index,
                    child: HeroAnimatingSubjectsCard(
                      subTitle: subtitle,
                      title: capitalize(allParsedBySubject[index].subject) +
                          " " +
                          allParsedBySubject[index].value,
                      color: color,
                      heroAnimation: AlwaysStoppedAnimation(0),
                      onPressed: MarksDetailTab(
                        eval: allParsedBySubject[index],
                        mode: allParsedBySubject[index].mode,
                        theme: allParsedBySubject[index].theme,
                        weight: allParsedBySubject[index].weight,
                        date: allParsedBySubject[index].dateString,
                        createDate: allParsedBySubject[index].createDateString,
                        teacher: allParsedBySubject[index].teacher,
                        subject: allParsedBySubject[index].subject,
                        numberValue: allParsedBySubject[index].numberValue,
                        value: allParsedBySubject[index].value,
                        formName: allParsedBySubject[index].formName,
                        form: allParsedBySubject[index].form,
                        id: index,
                        name: capitalize(allParsedBySubject[index].subject) +
                            " " +
                            allParsedBySubject[index].value,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } else {
      return SizedBox(
        width: double.infinity,
        height: 106,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Hero(
            tag: index,
            child: HeroAnimatingSubjectsCard(
              subTitle: subtitle,
              title: capitalize(allParsedBySubject[index].subject) +
                  " " +
                  allParsedBySubject[index].value,
              color: color,
              heroAnimation: AlwaysStoppedAnimation(0),
              onPressed: MarksDetailTab(
                eval: allParsedBySubject[index],
                mode: allParsedBySubject[index].mode,
                theme: allParsedBySubject[index].theme,
                weight: allParsedBySubject[index].weight,
                date: allParsedBySubject[index].dateString,
                createDate: allParsedBySubject[index].createDateString,
                teacher: allParsedBySubject[index].teacher,
                subject: allParsedBySubject[index].subject,
                numberValue: allParsedBySubject[index].numberValue,
                value: allParsedBySubject[index].value,
                formName: allParsedBySubject[index].formName,
                form: allParsedBySubject[index].form,
                id: index,
                name: capitalize(allParsedBySubject[index].subject) +
                    " " +
                    allParsedBySubject[index].value,
                color: color,
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      drawer: getDrawer(MarksTab.tag, context),
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
            if (tab.text.toLowerCase() == "dátum szerint") {
              if (globals.markCount == 0) {
                return noMarks();
              } else {
                return RefreshIndicator(
                  key: _androidRefreshKey,
                  onRefresh: () async {
                    await _refreshData();
                  },
                  child: ListView.builder(
                    itemCount: globals.markCount,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    itemBuilder: _dateListBuilder,
                  ),
                );
              }
            } else {
              if (globals.markCount == 0) {
                return noMarks();
              } else {
                return RefreshIndicator(
                  key: _androidRefreshKeyTwo,
                  onRefresh: () async {
                    await _refreshData();
                  },
                  child: ListView.builder(
                    itemCount: globals.markCount,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    itemBuilder: _subjectListBuilder,
                  ),
                );
              }
            }
          }).toList()),
    );
  }

  Widget noMarks() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonSadOutline,
        size: 50,
      ),
      Text(
        "Nincs még jegyed!",
        textAlign: TextAlign.center,
      )
    ]));
  }
}
