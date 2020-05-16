import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/screens/homework_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/functions/utils.dart';

List<Color> colors = [];
List<Homework> globalHomework = [];
//!Some users see weird behaviors when the app is opened from the background
//! IE: All of the subjects apear on one day

class HomeworkTab extends StatefulWidget {
  static String tag = 'homework';
  static const title = 'Házifeladat';

  @override
  _HomeworkTabState createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  @override
  void initState() {
    if (colors.length == 0 || colors == [])
      colors = getRandomColors(globalHomework.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeworkTab.title),
      ),
      drawer: getDrawer(HomeworkTab.tag, context),
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
      bool dueOver = false;
      var left = globalHomework[index].dueDate.difference(DateTime.now());
      if (left.inMinutes / 60 < 0) {
        dueOver = true;
      }
      String subTitle = "Határidő: " +
          globalHomework[index].dueDate.year.toString() +
          "-" +
          globalHomework[index].dueDate.month.toString() +
          "-" +
          globalHomework[index].dueDate.day.toString() +
          " " +
          parseIntToWeekdayString(globalHomework[index].dueDate.weekday);
      return SafeArea(
          top: false,
          bottom: false,
          child: AnimatedHomeworkCard(
            dueOver: dueOver,
            title: globalHomework[index].subject,
            subTitle: subTitle, //lessonsList[0][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: HomeworkDetailTab(
              color: colors[index],
              hwInfo: globalHomework[index],
            ),
          ));
    }
  }

  Widget noHomework() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonHappyOutline,
        size: 50,
      ),
      Text(
        "Nincs házifeladat!\n(Jelenleg csak a mostani hétre feladott leckét tudom mutatni)",
        textAlign: TextAlign.center,
      )
    ]));
  }
}
