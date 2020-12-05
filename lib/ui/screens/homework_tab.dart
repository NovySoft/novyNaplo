import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/homework.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/parseIntToWeekdayString.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/homework_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedHomeworkCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';

//TODO make groups by date and also some kind of dropdown style lists
//TODO: should also make a checkbox to save homework as selected
List<Color> colors = [];
List<Homework> globalHomework = [];

class HomeworkTab extends StatefulWidget {
  static String tag = 'homework';
  static String title = capitalize(getTranslatedString("hw"));

  @override
  _HomeworkTabState createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Homeworks");
    if (colors.length == 0 ||
        colors == [] ||
        colors.length < globalHomework.length) {
      colors = getRandomColors(globalHomework.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeworkTab.title),
      ),
      drawer: GlobalDrawer.getDrawer(HomeworkTab.tag, context),
      body: _body(),
    );
  }

  Widget _body() {
    if (globalHomework.length == 0) {
      return noHomework();
    } else {
      return ListView.builder(
        itemCount: globalHomework.length + globals.adModifier,
        itemBuilder: _listBuilder,
      );
    }
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= globalHomework.length) {
      return SizedBox(
        height: 100,
      );
    } else {
      //Hide if it doesn't needed
      DateTime afterDue = globalHomework[index].hataridoDatuma;
      if (globals.howLongKeepDataForHw != -1) {
        afterDue =
            afterDue.add(Duration(days: globals.howLongKeepDataForHw.toInt()));
        if (afterDue.compareTo(DateTime.now()) < 0) {
          return SizedBox(height: 0, width: 0);
        }
      }

      bool dueOver = false;
      var left =
          globalHomework[index].hataridoDatuma.difference(DateTime.now());
      if (left.inMinutes / 60 < 0) {
        dueOver = true;
      }
      String subTitle = "${getTranslatedString("due")}: " +
          globalHomework[index].hataridoDatuma.toDayOnlyString() +
          " " +
          parseIntToWeekdayString(globalHomework[index].hataridoDatuma.weekday);
      return SafeArea(
        child: AnimatedHomeworkCard(
          dueOver: dueOver,
          title: globalHomework[index].tantargy.nev,
          subTitle: subTitle, //lessonsList[0][index].classroom,
          color: colors[index],
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: HomeworkDetailTab(
            color: colors[index],
            hwInfo: globalHomework[index],
          ),
        ),
      );
    }
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
}
