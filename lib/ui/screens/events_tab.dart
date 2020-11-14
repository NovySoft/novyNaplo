import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/event.dart';

import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/events_detail_tab.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/AnimatedTitleSubtitleCard.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';

List<Event> allParsedEvents = [];
List<Color> colors = [];

class EventsTab extends StatefulWidget {
  static String tag = "Events-tab";
  @override
  _EventsTabState createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Events");
    if (colors.length == 0 ||
        colors == [] ||
        colors.length < allParsedEvents.length) {
      colors = getRandomColors(allParsedEvents.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("events")),
      ),
      drawer: GlobalDrawer.getDrawer(EventsTab.tag, context),
      body: _body(),
    );
  }

  Widget _body() {
    if (allParsedEvents.length == 0) {
      return noEvent();
    } else {
      return ListView.builder(
        itemCount: allParsedEvents.length + globals.adModifier,
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
      return SafeArea(
          child: AnimatedTitleSubtitleCard(
        heroAnimation: AlwaysStoppedAnimation(0),
        title: allParsedEvents[index].cim,
        subTitle: allParsedEvents[index].tartalom.length >= 15
            ? allParsedEvents[index].tartalom.substring(0, 15)
            : allParsedEvents[index].tartalom,
        color: colors[index],
        onPressed: EventsDetailTab(
          color: colors[index],
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
