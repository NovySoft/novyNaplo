import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final List<Tab> days = <Tab>[
  Tab(text: 'Hétfő'),
  Tab(text: 'Kedd'),
  Tab(text: 'Szerda'),
  Tab(text: 'Csütörtök'),
  Tab(text: 'Péntek'),
  Tab(text: 'Szombat'),
  Tab(text: 'Vasárnap'),
];

class TimetableTab extends StatefulWidget {
  static String tag = 'timetable';
  @override
  _TimetableTabState createState() => new _TimetableTabState();
}

class _TimetableTabState extends State<TimetableTab> {
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
          drawer: Drawer(), //TODO make drawer
          appBar: new AppBar(
            title: new Text("timetable" + "startDateText"),
            bottom: TabBar(
              tabs: days,
            ),
          ),
          body: TabBarView(
              children: days.map((Tab tab) {
            final String label = tab.text.toLowerCase();
            return ListView.builder(
              itemCount: 7,
              itemBuilder: _timetableBuilder,
            );
          }).toList())),
    );
  }
}

Widget _timetableBuilder(BuildContext context, int index) {
  return Text(index.toString());
}
