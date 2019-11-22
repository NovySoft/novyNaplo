import 'package:flutter/material.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/marks_tab.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/login_page.dart';
import 'package:novynaplo/functions/parseMarks.dart';

var subjectName = [];
var subjectAvg = [];
var subjectClassAvg = [];
var subjectDiff = [];
var avgColor = [];

class AvaragesTab extends StatelessWidget {
  static String tag = 'avarages';
  static const title = 'Átlagok';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AvaragesTab.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child:
                    Center(child: new Image.asset(menuLogo, fit: BoxFit.fill))),
            ListTile(
              title: Text('Jegyek'),
              leading: Icon(Icons.create),
              onTap: () {
                try {
                  Navigator.pushNamed(context, MarksTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Átlagok'),
              leading: Icon(Icons.all_inclusive),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return avaragesList(context);
  }
}

void setArrays(var n) {
  subjectName.add(n.subject.toString());
  subjectAvg.add(n.ownValue.toString());
  subjectClassAvg.add(n.classValue.toString());
  subjectDiff.add(n.diff.toString());
  if(n.ownValue < 2.5){
    avgColor.add(Colors.redAccent[700]);
  }else if(n.ownValue < 3 && n.ownValue >= 2.5){
    avgColor.add(Colors.redAccent);
  }else if(n.ownValue < 4 && n. ownValue >= 3){
    avgColor.add(Colors.yellow[800]);
  }else{
    avgColor.add(Colors.green);
  }
}

Widget avaragesList(BuildContext context) {
  subjectName = [];
  subjectAvg = [];
  subjectClassAvg = [];
  subjectDiff = [];
  avgColor = [];
  parseAvarages(dJson).forEach((n) => setArrays(n));
  return ListView.separated(
    separatorBuilder: (context, index) => Divider(),
    itemCount: avarageCount,
    itemBuilder: (context, index) {
      return ListTile(
          title: Text(subjectName[index], style: TextStyle(color: avgColor[index])),
          trailing: Text(subjectAvg[index], style: TextStyle(color: avgColor[index])),
      );
    },
  );
}
