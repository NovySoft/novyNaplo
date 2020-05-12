import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;

List<Notices> allParsedNotices;
var colors = getRandomColors(allParsedNotices.length);

class NoticesTab extends StatefulWidget {
  static String tag = 'notices';
  static const title = 'Feljegyzések';

  @override
  _NoticesTabState createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(NoticesTab.title),
      ),
      drawer: getDrawer(NoticesTab.tag, context),
      body: _body(context),
    );
  }

  @override
  void initState() {
    if (globals.payloadId != -1) {
      int tempindex = allParsedNotices.indexWhere(
        (element) {
          return element.id == globals.payloadId;
        },
      );
      Notices tempNotice = allParsedNotices.firstWhere(
        (element) {
          return element.id == globals.payloadId;
        },
        orElse: () {
          return new Notices();
        },
      );
      //Evals tempEval = allParsedByDate[0];
      if (tempNotice.id != null)
        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoticeDetailTab(
                id: tempindex,
                title: tempNotice.title,
                teacher: tempNotice.teacher,
                content: tempNotice.content,
                date: tempNotice.dateString,
                subject: tempNotice.subject,
                color: colors[tempindex],
              ),
            ),
          );
        });
      globals.payloadId = -1;
    }
    super.initState();
    onInit();
  }
}

Widget _body(BuildContext context) {
  if (allParsedNotices.length == 0) {
    return noNotice();
  } else {
    return ListView.builder(
      itemCount: allParsedNotices.length + globals.adModifier,
      padding: EdgeInsets.symmetric(vertical: 12),
      itemBuilder: _noticesBuilder,
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
      "Nincs még feljegyzésed!",
      textAlign: TextAlign.center,
    )
  ]));
}

Widget _noticesBuilder(BuildContext context, int index) {
  onInit();
  if (index >= allParsedNotices.length) {
    return SizedBox(
      height: 100,
    );
  } else {
    Color currColor = colors[index];
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
          title: allParsedNotices[index].title,
          subTitle: allParsedNotices[index].teacher,
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: NoticeDetailTab(
            id: index,
            title: allParsedNotices[index].title,
            teacher: allParsedNotices[index].teacher,
            content: allParsedNotices[index].content,
            date: allParsedNotices[index].dateString,
            subject: allParsedNotices[index].subject,
            color: currColor,
          ),
        ));
  }
}

void onInit() {
  if (colors == [] || colors == null)
    colors = getRandomColors(allParsedNotices.length);
}
