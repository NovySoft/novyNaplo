import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/events_detail_tab.dart';

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
    if (colors.length == 0 || colors == []) {
      colors = getRandomColors(allParsedEvents.length);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("Faliújság"),
      ),
      drawer: getDrawer(EventsTab.tag, context),
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
          top: false,
          bottom: false,
          child: AnimatedTitleSubtitleCard(
            heroAnimation: AlwaysStoppedAnimation(0),
            title: allParsedEvents[index].title,
            subTitle: allParsedEvents[index].content.substring(0, 15),
            color: colors[index],
            onPressed: EventsDetailTab(
              color: colors[index],
              eventDetails: allParsedEvents[index],
            ),
          ));
    }
  }

  Widget noEvent() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonHappyOutline,
        size: 50,
      ),
      Text(
        "Nincs semmi a faliújságon!",
        textAlign: TextAlign.center,
      )
    ]));
  }
}
