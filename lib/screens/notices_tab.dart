import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;

var allParsedNotices;
var colors = getRandomColors(globals.noticesCount);

class NoticesTab extends StatefulWidget {
  static String tag = 'notices';
  static const title = 'Feljegyzések';

  @override
  _NoticesTabState createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab> {
  @override
  Widget build(BuildContext context) {
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
    super.initState();
    onInit();
  }
}

Widget _body(BuildContext context) {
  if (globals.noticesCount == 0) {
    return noNotice();
  } else {
    return ListView.builder(
      itemCount: globals.noticesCount + globals.adModifier,
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
  //TODO write this function
}
