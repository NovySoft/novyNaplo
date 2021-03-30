import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/exam.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;

class ExamsDetailTab extends StatelessWidget {
  ExamsDetailTab({@required this.exam, this.color});
  final Exam exam;
  final Color color;
  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log("Shown Exams_detail_tab");
    return Scaffold(
      appBar: AppBar(title: Text(capitalize(exam.theme))),
      body: _buildBody(exam, color),
    );
  }
}

Widget _buildBody(Exam exam, Color color) {
  return SafeArea(
    child: CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,
          title: new Container(),
          leading: new Container(),
          backgroundColor: color == null ? Colors.green : color,
          expandedHeight: 250.0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.parallax,
            stretchModes: [StretchMode.zoomBackground],
            background: Icon(
              exam.icon,
              size: 150,
              color: globals.examsCardTheme == "Dark"
                  ? Colors.grey[350]
                  : Colors.black38,
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              Widget child = getExamDetails(exam, context, index);
              return Row(
                children: [
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: child,
                  ),
                ],
              );
            },
            childCount: 13,
          ),
        ),
      ],
    ),
  );
}

Widget getExamDetails(Exam exam, BuildContext context, int index) {
  switch (index) {
    case 0:
      return Padding(
        padding: const EdgeInsets.only(left: 15, top: 16, bottom: 16),
        child: Text(
          '${getTranslatedString("examInfo")}:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
      break;
    case 1:
      return SizedBox(
        child: Text("${getTranslatedString("subject")}: " + exam.subject.name,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 3:
      return SizedBox(
        child: Text("${getTranslatedString("theme")}: " + exam.theme,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 5:
      return SizedBox(
        child: Text(
            "${getTranslatedString("examType")}: " + exam.mode.description,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 7:
      return SizedBox(
        child: Text("${getTranslatedString("teacher")}: " + exam.teacher,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 9:
      DateTime examDate = exam.dateOfWriting;
      String subtitle =
          "${examDate.toHumanString()} (${exam.lessonNumber.intToTHEnding()} ${getTranslatedString("lesson")})";
      return SizedBox(
        child: Text("${getTranslatedString("dateWrite")}: " + subtitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 11:
      DateTime examDate = exam.announcementDate;
      String subtitle = "${examDate.toHumanString()}";
      return SizedBox(
        child: Text("${getTranslatedString("dateGiveUp")}: " + subtitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      );
      break;
    case 12:
      return SizedBox(
        height: 250,
      );
      break;
    default:
      return SizedBox(height: 10);
  }
}
