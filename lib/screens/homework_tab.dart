import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/screens/homework_detail_tab.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/functions/utils.dart';

List<Color> colors = [];

class HomeworkTab extends StatefulWidget {
  static String tag = 'homework';
  static const title = 'Házifeladat';

  @override
  _HomeworkTabState createState() => _HomeworkTabState();
}

class _HomeworkTabState extends State<HomeworkTab> {
  @override
  void initState() {
    colors = getRandomColors(globals.globalHomework.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(HomeworkTab.title),
      ),
      drawer: getDrawer(HomeworkTab.tag, context),
      body: _body(),
    );
  }

  Widget _body() {
    if (globals.globalHomework.length == 0) {
      return noHomework();
    } else {
      return ListView.builder(
        itemCount: globals.globalHomework.length + globals.adModifier,
        itemBuilder: _listBuilder,
      );
    }
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= globals.globalHomework.length) {
      return SizedBox(
        height: 100,
      );
    } else {
      String subTitle = globals.globalHomework[index].givenUp.year.toString() +
          "-" +
          globals.globalHomework[index].givenUp.month.toString() +
          "-" +
          globals.globalHomework[index].givenUp.day.toString() +
          " " +
          parseIntToWeekdayString(
              globals.globalHomework[index].givenUp.weekday);
      return SafeArea(
          top: false,
          bottom: false,
          child: AnimatedTitleSubtitleCard(
            title: globals.globalHomework[index].subject,
            subTitle: subTitle, //lessonsList[0][index].classroom,
            color: colors[index],
            heroAnimation: AlwaysStoppedAnimation(0),
            onPressed: HomeworkDetailTab(
              color: colors[index],
              hwInfo: globals.globalHomework[index],
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
      Text("Nincs házifeladat!\n(Jelenleg csak a mostani hétre feladott leckét tudom mutatni)",textAlign: TextAlign.center,)
    ]));
  }
}
