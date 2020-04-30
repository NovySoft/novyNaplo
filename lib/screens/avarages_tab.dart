import 'package:flutter/material.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
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
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(AvaragesTab.title),
      ),
      drawer: getDrawer(AvaragesTab.tag, context),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
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
  if (n.ownValue == 0 || n.ownValue == null) {
    var jegyek = parseAllByDate(globals.dJson);
    tmpArray = [];
    tmpI = 0;
    for (var a in jegyek) {
      setNumberValue(a, n.subject);
    }
    num sum = 0;
    for (var e in tmpArray) {
      sum += e;
    }
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
  if (avg == null) {
    avgColor.add(Colors.red);
  } else if (avg < 2.5) {
    avgColor.add(Colors.redAccent[700]);
  } else if (avg < 3 && avg >= 2.5) {
    avgColor.add(Colors.redAccent);
  } else if (avg < 4 && avg >= 3) {
    avgColor.add(Colors.yellow[800]);
  } else {
    avgColor.add(Colors.green);
  }
}

//TODO refactor to parse avarages before the rendering process
Widget avaragesList(BuildContext context) {
  subjectName = [];
  subjectAvg = [];
  subjectClassAvg = [];
  subjectDiff = [];
  avgColor = [];
  for (var n in parseAvarages(globals.avJson)) {
    setArrays(n);
  }
  return ListView.separated(
    separatorBuilder: (context, index) => Divider(),
    itemCount: globals.avarageCount + globals.adModifier,
    itemBuilder: (context, index) {
      if (index >= globals.avarageCount) {
        return ListTile(
          title: SizedBox(
            height: 100,
          ),
        );
      } else {
        return ListTile(
          title: Text(subjectName[index],
              style: TextStyle(color: avgColor[index])),
          trailing:
              Text(subjectAvg[index], style: TextStyle(color: avgColor[index])),
        );
      }
    },
  );
}
