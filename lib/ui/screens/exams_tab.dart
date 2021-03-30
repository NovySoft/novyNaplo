import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Exams");
    super.initState();
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
      return ListView.builder(
        itemCount: allParsedExams.length,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _examBuilder,
      );
    }
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

  Widget _examBuilder(BuildContext context, int index) {
    //TODO: Matrix and title like in absences
    if (index >= allParsedExams.length) {
      return SizedBox(
        height: 100,
      );
    } else {
      bool isDone = false;
      DateTime examDate = allParsedExams[index].dateOfWriting;
      String subtitle =
          "${examDate.toDayOnlyString()} ${parseIntToWeekdayString(examDate.weekday)} (${allParsedExams[index].lessonNumber.intToTHEnding()} ${getTranslatedString("lesson")})";
      if (DateTime.now().compareTo(
              allParsedExams[index].dateOfWriting.add(Duration(days: 1))) >
          0) {
        isDone = true;
      }
      Color currColor = getExamsCardColor(index);
      return SafeArea(
        child: AnimatedExamsCard(
          isDone: isDone,
          title: allParsedExams[index].theme,
          subTitle: subtitle,
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: ExamsDetailTab(
            color: currColor,
            exam: allParsedExams[index],
          ),
        ),
      );
    }
  }
}
