import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/exams_detail_tab.dart';

List<Exam> allParsedExams = [];
List<Color> colors = [];

class ExamsTab extends StatefulWidget {
  static String tag = 'exams-page';
  @override
  _ExamsTabState createState() => _ExamsTabState();
}

class _ExamsTabState extends State<ExamsTab> {
  @override
  void initState() {
    print(allParsedExams.length);
    colors = getRandomColors(allParsedExams.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bejelentett dolgozatok"),
      ),
      drawer: getDrawer(ExamsTab.tag, context),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    if (allParsedExams.length == 0) {
      return noNotice();
    } else {
      return ListView.builder(
        itemCount: allParsedExams.length + globals.adModifier,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _examBuilder,
      );
    }
  }

  Widget noNotice() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonHappyOutline,
        size: 50,
      ),
      Text(
        "Nincs még bejelentett dolgozat!",
        textAlign: TextAlign.center,
      )
    ]));
  }

  Widget _examBuilder(BuildContext context, int index) {
    if (index >= allParsedExams.length) {
      return SizedBox(
        height: 100,
      );
    } else {
      return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
          title: allParsedExams[index].nameOfExam,
          subTitle: capitalize(allParsedExams[index].subject),
          color: colors[index],
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: ExamsDetailTab(
            color: colors[index],
            exam: allParsedExams[index],
          ),
        ),
      );
    }
  }
}
