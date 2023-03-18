import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:novynaplo/helpers/misc/removeHTMLtags.dart';
import 'package:novynaplo/helpers/ui/cardColor/noticesAndEventsCard.dart';
import 'package:novynaplo/ui/screens/events_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedTitleSubtitleCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/textColor/drawerText.dart';

List<Event> allParsedEvents = [];

class EventsTab extends StatefulWidget {
  static String tag = "Events-tab";
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Events");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("events")),
        backgroundColor:
            globals.appBarColoredByUser ? globals.currentUser.color : null,
        foregroundColor: getDrawerForeground(),
      ),
      drawerScrimColor:
          globals.darker ? Colors.black.withOpacity(0) : Colors.black54,
      drawer: CustomDrawer(EventsTab.tag),
      body: _body(),
    );
  }

  Widget _body() {
    if (allParsedEvents.length == 0) {
      return noEvent();
    } else {
      return ListView.builder(
        itemCount: allParsedEvents.length,
        itemBuilder: _listBuilder,
      );
    }
  }

  Widget _listBuilder(BuildContext context, int index) {
    if (index >= allParsedEvents.length) {
      return SizedBox(
        height: 100,
      );
    } else {
      Color currColor = getNoticesAndEventsCardColor(index);
      return SafeArea(
          child: AnimatedTitleSubtitleCard(
        textColor: globals.noticesAndEventsCardTheme == "Dark"
            ? Colors.grey[350]
            : Colors.black,
        heroAnimation: AlwaysStoppedAnimation(0),
        title: allParsedEvents[index].title,
        subTitle: removeHTMLtags(allParsedEvents[index].content),
        color: currColor,
        onPressed: EventsDetailTab(
          color: currColor,
          eventDetails: allParsedEvents[index],
        ),
      ));
    }
  }

  Widget noEvent() {
    //TODO Make a small animation instead of a static image
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonHappyOutline,
        size: 50,
      ),
      Text(
        "${getTranslatedString("noEvents")}!",
        textAlign: TextAlign.center,
      )
    ]));
  }
}
