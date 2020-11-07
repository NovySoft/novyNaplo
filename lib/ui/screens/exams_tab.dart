import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/exam.dart';

import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/exams_detail_tab.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedExamsCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';

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
    FirebaseCrashlytics.instance.log("Shown Exams");
    colors = getRandomColors(allParsedExams.length);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("exams")),
      ),
      drawer: GlobalDrawer.getDrawer(ExamsTab.tag, context),
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
        "${getTranslatedString("noExam")}!",
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
      bool isDone = false;
      DateTime examDate = allParsedExams[index].dateWrite;
      String subtitle = "${examDate.year}-${examDate.month}-${examDate.day}";
      if (DateTime.now().compareTo(allParsedExams[index].dateWrite) > 0) {
        isDone = true;
      }
      return SafeArea(
        child: AnimatedExamsCard(
          isDone: isDone,
          title: allParsedExams[index].nameOfExam,
          subTitle: subtitle,
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
