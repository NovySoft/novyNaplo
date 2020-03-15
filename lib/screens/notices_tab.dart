import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';

var allParsedNotices;
var colors = getRandomColors(noticesCount);

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
      body: ListView.builder(
        itemCount: noticesCount,
        padding: EdgeInsets.symmetric(vertical: 12),
        itemBuilder: _noticesBuilder,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    onInit();
  }
}

Widget _noticesBuilder(BuildContext context, int index) {
  MaterialColor currColor = colors[index];
  return SafeArea(
      top: false,
      bottom: false,
      child: AnimatedTitleSubtitleCard(
          title: allParsedNotices[index].title,
          subTitle: allParsedNotices[index].teacher,
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute(
                builder: (context) => NoticeDetailTab(
                  id: index,
                  title: allParsedNotices[index].title,
                  teacher: allParsedNotices[index].teacher,
                  content: allParsedNotices[index].content,
                  date: allParsedNotices[index].dateString,
                  subject: allParsedNotices[index].subject,
                  color: currColor,
                ),
              ),
            );
          }));
}

void onInit() {
  //TODO write this function
}
