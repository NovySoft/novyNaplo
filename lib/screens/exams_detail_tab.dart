import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;

class ExamsDetailTab extends StatelessWidget {
  ExamsDetailTab({@required this.exam, this.color});
  final Exam exam;
  final Color color;
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(title: Text(capitalize(exam.nameOfExam))),
      body: _buildBody(exam, color),
    );
  }
}

Widget _buildBody(Exam exam, Color color) {
  return SafeArea(
    bottom: false,
    left: false,
    right: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HeroAnimatingMarksCard(
          eval: null,
          iconData: parseSubjectToIcon(subject: exam.subject),
          subTitle: "",
          title: capitalize(exam.subject + " " + exam.nameOfExam),
          color: color,
          heroAnimation: AlwaysStoppedAnimation(1),
          onPressed: null,
        ),
        Divider(
          height: 0,
          color: Colors.grey,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                    child: Text(
                      'Dolgozat információk:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                  break;
                case 1:
                  return SizedBox(
                    child: Text("Tantárgy: " + exam.subject,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 2:
                  return SizedBox(
                    child: Text("Téma: " + exam.nameOfExam,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 3:
                  return SizedBox(
                    child: Text(
                        "Dolgozat típusa: " + exam.typeOfExam.toString(),
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 4:
                  return SizedBox(
                    child: Text("Tanár: " + exam.teacher,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 5:
                  DateTime examDate = exam.dateWrite;
                  String subtitle =
                      "${examDate.year}-${examDate.month}-${examDate.day} ${examDate.hour}:${examDate.minute}";
                  return SizedBox(
                    child: Text("Írás dátuma: " + subtitle,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                case 6:
                  DateTime examDate = exam.dateGivenUp;
                  String subtitle =
                      "${examDate.year}-${examDate.month}-${examDate.day} ${examDate.hour}:${examDate.minute}";
                  return SizedBox(
                    child: Text("Feladás dátuma: " + subtitle,
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                  );
                  break;
                default:
                  return SizedBox(height: 25);
              }
            },
          ),
        ),
      ],
    ),
  );
}
