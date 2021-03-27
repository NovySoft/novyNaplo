import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/notice.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/notices_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedTitleSubtitleCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/global.dart' as globals;

List<Notice> allParsedNotices = [];
var colors = getRandomColors(allParsedNotices.length);

class NoticesTab extends StatefulWidget {
  static String tag = 'notices';
  static String title = getTranslatedString("notices");

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
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: GlobalDrawer.getDrawer(NoticesTab.tag, context),
      body: _body(context),
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseCrashlytics.instance.log("Shown Notices");
    if (colors == [] ||
        colors == null ||
        colors.length < allParsedNotices.length) {
      colors = getRandomColors(allParsedNotices.length);
    }
  }
}

Widget _body(BuildContext context) {
  if (allParsedNotices.length == 0) {
    return noNotice();
  } else {
    return ListView.builder(
      itemCount: allParsedNotices.length,
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
      "${getTranslatedString("noNotice")}!",
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
      child: AnimatedTitleSubtitleCard(
        title: allParsedNotices[index].title,
        subTitle: allParsedNotices[index].teacher,
        color: currColor,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: NoticeDetailTab(
          color: currColor,
          notice: allParsedNotices[index],
        ),
      ),
    );
  }
}
