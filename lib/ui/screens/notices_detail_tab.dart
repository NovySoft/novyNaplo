import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/misc/parseIntToWeekdayString.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticeDetailTab extends StatelessWidget {
  const NoticeDetailTab({
    this.color,
    this.notice,
    this.id,
  });

  final int id;
  final Notice notice;
  final Color color;

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log("Shown Notices_detail_tab");
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(),
      body: body(),
    );
  }

  Widget body() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 60,
            child: DecoratedBox(
                decoration: BoxDecoration(color: color),
                child: Center(
                  child: Text(
                    notice.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25, color: Colors.black),
                  ),
                )),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 4 + globals.adModifier,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("content")}:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        Linkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            } else {
                              throw 'Could not launch $link';
                            }
                          },
                          text: capitalize(notice.content),
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    );
                    break;
                  case 1:
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          Text(
                            "${getTranslatedString("teacher")}:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            notice.teacher,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ]);
                    break;
                  case 2:
                    DateTime date = notice.date;
                    String dateSimplified =
                        "${date.toDayOnlyString()} ${parseIntToWeekdayString(date.weekday)}";
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 15),
                          Text(
                            "${getTranslatedString("date")}:",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            dateSimplified,
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ]);
                    break;
                  case 3:
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 15),
                        Text(
                          "${getTranslatedString("subject")}:",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          notice.subject == null
                              ? getTranslatedString("unknown")
                              : capitalize(notice.subject.name),
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20.0),
                        ),
                      ],
                    );
                    break;
                }
                return SizedBox(height: 250, width: 10);
              },
            ),
          ),
        ],
      ),
    );
  }
}
