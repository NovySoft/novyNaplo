import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:novynaplo/data/models/event.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/global.dart' as globals;

class EventsDetailTab extends StatefulWidget {
  const EventsDetailTab({
    @required this.eventDetails,
    @required this.color,
  });

  final Event eventDetails;
  final Color color;

  @override
  _EventsDetailTabState createState() => _EventsDetailTabState();
}

class _EventsDetailTabState extends State<EventsDetailTab> {
  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Events_detail_tab");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.color),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.eventDetails.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          color: globals.noticesAndEventsCardTheme == "Dark"
                              ? Colors.grey[350]
                              : Colors.black,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        widget.eventDetails.startDate.toHumanString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: globals.noticesAndEventsCardTheme == "Dark"
                              ? Colors.grey[350]
                              : Colors.black,
                        ),
                      ),
                      Text(
                        "-",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: globals.noticesAndEventsCardTheme == "Dark"
                              ? Colors.grey[350]
                              : Colors.black,
                        ),
                      ),
                      Text(
                        widget.eventDetails.endDate.toHumanString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: globals.noticesAndEventsCardTheme == "Dark"
                              ? Colors.grey[350]
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Html(
                    data: widget.eventDetails.content,
                    onLinkTap: (url) async {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        FirebaseAnalytics().logEvent(
                          name: "LinkFail",
                          parameters: {"link": url},
                        );
                        throw 'Could not launch $url';
                      }
                    },
                    style: {
                      "*": Style(
                        fontSize: FontSize(18.75),
                      ),
                    },
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
