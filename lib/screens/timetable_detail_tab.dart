import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';

class TimetableDetailTab extends StatelessWidget {
  const TimetableDetailTab({
    this.lessonInfo,
    this.color,
  });

  final Lesson lessonInfo;
  final MaterialColor color;
  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: id,
            child: HeroAnimatingMarksCard(
              title: lessonInfo.name,
              color: color,
              heroAnimation: AlwaysStoppedAnimation(1),
            ),
            flightShuttleBuilder: (context, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return HeroAnimatingMarksCard(
                title: lessonInfo.name,
                color: color,
                heroAnimation: animation,
              );
            },
          ),
          Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                      child: Text(
                        'Óra információk:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                    break;
                  case 1:
                    return SizedBox(
                      child: Text("Az óra neve: " + lessonInfo.name,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 2:
                    return SizedBox(
                      child: Text("Óra témája: " + lessonInfo.theme,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 3:
                    return SizedBox(
                      child: Text("Tantárgy: " + lessonInfo.subject,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 4:
                    return SizedBox(
                      child: Text("Terem: " + lessonInfo.classroom,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 5:
                    return SizedBox(
                      child: Text("Tanár: " + lessonInfo.teacher,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 6:
                    return SizedBox(
                      child: Text(
                          "Helyettesítő Tanár (ha van): " +
                              lessonInfo.deputyTeacherName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 7:
                    String date = lessonInfo.date.year.toString() +
                        "-" +
                        lessonInfo.date.month.toString() +
                        "-" +
                        lessonInfo.date.day.toString();
                    return SizedBox(
                      child: Text("Dátum: " + date,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 8:
                    String startMinutes;
                    if (lessonInfo.startDate.minute
                        .toString()
                        .startsWith("0")) {
                      startMinutes =
                          lessonInfo.startDate.minute.toString() + "0";
                    } else {
                      startMinutes = lessonInfo.startDate.minute.toString();
                    }
                    String endMinutes;
                    if (lessonInfo.endDate.minute.toString().startsWith("0")) {
                      endMinutes = lessonInfo.endDate.minute.toString() + "0";
                    } else {
                      endMinutes = lessonInfo.endDate.minute.toString();
                    }
                    String start = lessonInfo.startDate.hour.toString() +
                        ":" +
                        startMinutes;
                    String end =
                        lessonInfo.endDate.hour.toString() + ":" + endMinutes;
                    return SizedBox(
                      child: Text("Kezdés-befejezés: " + start + " - " + end,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 9:
                    Duration diff =
                        lessonInfo.endDate.difference(lessonInfo.startDate);
                    return SizedBox(
                      child: Text(
                          "Időtartam: " + diff.inMinutes.toString() + " perc",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 10:
                    return SizedBox(
                      child: Text(
                          "Osztály: " + lessonInfo.groupName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  default:
                    return SizedBox(height: 18);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(lessonInfo.name)),
      body: _buildBody(),
    );
  }
}
