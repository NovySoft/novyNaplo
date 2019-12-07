import 'package:flutter/material.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/functions/utils.dart';

var subjectName = [];
var subjectAvg = [];
var subjectClassAvg = [];
var subjectDiff = [];
var avgColor = [];
var tmpArray = [];
var tmpI = 0;

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
            ListTile(
              title: Text('Feljegyzések'),
              leading: Icon(Icons.layers),
              onTap: () {
                try {
                  Navigator.pushNamed(context, NoticesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Beállítások'),
              leading: Icon(Icons.settings_applications),
              onTap: () {
                try {
                  Navigator.pushNamed(context, SettingsTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
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

void setNumberValue(var a, subject) {
  //print("Compare: " +toEnglish(a.subject)+ " and " +toEnglish(subject)+ "value:"+ a.numberValue.toString());
  if (toEnglish(a.subject) == toEnglish(subject)) {
    tmpArray.add(a.numberValue);
    tmpI++;
  }
}

void setArrays(var n) {
  double avg = 0;
  subjectName.add(n.subject.toString());
  if (n.ownValue == 0) {
    var jegyek = parseAll(dJson);
    tmpArray = [];
    tmpI = 0;
    jegyek.forEach((a) => setNumberValue(a, n.subject));
    num sum = 0;
    tmpArray.forEach((e) {
      sum += e;
    });
    if (sum == 0) {
      subjectAvg.add("Nincs jegyed!");
      avg = 0;
    } else {
      subjectAvg.add((sum / tmpI).toString());
      avg = sum / tmpI;
    }
  } else {
    subjectAvg.add(n.ownValue.toString());
    avg = n.ownValue;
  }
  subjectClassAvg.add(n.classValue.toString());
  subjectDiff.add(n.diff.toString());
  if (avg < 2.5) {
    avgColor.add(Colors.redAccent[700]);
  } else if (avg < 3 && avg >= 2.5) {
    avgColor.add(Colors.redAccent);
  } else if (avg < 4 && avg >= 3) {
    avgColor.add(Colors.yellow[800]);
  } else {
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
        title:
            Text(subjectName[index], style: TextStyle(color: avgColor[index])),
        trailing:
            Text(subjectAvg[index], style: TextStyle(color: avgColor[index])),
      );
    },
  );
}
