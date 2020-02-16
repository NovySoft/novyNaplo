import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/screens/settings_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/charts_tab.dart';

List<String> dropdownValues = [""];
String dropdownValue = dropdownValues[0];
List<Avarage> avarageList;
int currentIndex = 0;

class CalculatorTab extends StatefulWidget {
  static String tag = 'calculator';
  static const title = 'Jegyszámoló';

  @override
  CalculatorTabState createState() => CalculatorTabState();
}

class CalculatorTabState extends State<CalculatorTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              title: Text('Órarend'),
              leading: Icon(Icons.today),
              onTap: () {
                try {
                  Navigator.pushNamed(context, TimetableTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Átlagok'),
              leading: Icon(Icons.all_inclusive),
              onTap: () {
                try {
                  Navigator.pushNamed(context, AvaragesTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
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
              title: Text('Grafikonok'),
              leading: Icon(Icons.timeline),
              onTap: () {
                try {
                  Navigator.pushNamed(context, ChartsTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Jegyszámoló'),
              leading: new Icon(MdiIcons.calculator),
              onTap: () {
                Navigator.pop(context);
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
      appBar: AppBar(
        title: Text(CalculatorTab.title),
      ),
      body: _calculatorBody(),
    );
  }

  Widget _calculatorBody() {
    return Column(
      children: <Widget>[
        Container(
          child: DropdownButton<String>(
            value: dropdownValue,
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            underline: Container(
              color: Theme.of(context).accentColor,
              height: 2,
            ),
            onChanged: (String newValue) {
              setState(() {
                dropdownValue = newValue;
                currentIndex = dropdownValues.indexOf(newValue);
              });
            },
            items: dropdownValues.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          alignment: Alignment(0, 0),
          margin: EdgeInsets.all(5),
        ),
        Text(currentIndex.toString()),
      ],
    );
  }
}

/// Get the easiest way to get to a specific avarage
/// Parameters:
///
/// ```dart
/// getEasiest(jegyekÖsszege,jegyekSzáma,mennyiJegyAlattt,elAkarÉrni)
/// ```
String getEasiest(num jegyek, jsz, th, elak) {
  //jegyek = "jegyeid összege"
  //jsz = "jegyeid száma"
  //th = "mennyi jegy alatt akarod elérni?"
  //elak = "milyen átlagot akarsz elérni?"

  var atlag = jegyek / jsz; //átlag
  var x = elak * jsz +
      elak * th -
      jegyek; //mennyi jegyet kell hozzáadni, hogy elérjük az adottátlagot

  var j2 = th *
      5; // rontásnál mennyi jegyet kell hozzáadni, hogy elérjük az adottátlagot
  var j1 = jegyek + j2 / jsz + th; // az átlag amit a rontásnál számolunk

  bool isInteger(num value) => value is int || value == value.roundToDouble();

  if (!isInteger(x)) {
    x = x.round();
  }

  while (j1 > elak) {
    j2 = j2 - 1;
    j1 = (jegyek + j2) / (th + jsz);
  }

  if (!isInteger(j1)) {
    j1 = j1.round();
  }

  var t = th;
  var n = 0;
  String c = (x / th).toString();

  String cc = (j2 / th).toString();

  num ww = num.parse(cc.substring(0, 1));
  num w = num.parse(c.substring(0, 1));

  if (elak >= atlag) {
    if (x - 5 * th > 0) {
      return "Nem lehetséges";
    } else {
      switch (w) {
        case 1:
          while (t + n * 2 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db kettes és $t db egyes";
          break;
        case 2:
          while (t * 2 + n * 3 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db hármas és $t db kettes";
          break;
        case 3:
          while (t * 3 + n * 4 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyes és $t db hármas";
          break;
        case 4:
          while (t * 4 + n * 5 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyes és $t db ötös";
          break;
        case 5:
          return "$th db ötös";
          break;
        default:
          return "Nem lehetséges";
          break;
      }
    }
  } else {
    if (j2 - th < 0) {
      return "Nem lehetséges";
    } else {
      switch (ww) {
        case 1:
          while (t + n * 2 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db kettes és $t db egyes";
          break;
        case 2:
          while (t * 2 + n * 3 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db hármas és $t db kettes";
          break;
        case 3:
          while (t * 3 + n * 4 != j2) {
            t = t - 1;
            n = n + 1;
          }
          break;
        case 4:
          while (t * 4 + n * 5 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyes és $t db ötös";
          break;
        default:
          return "Nem lehetséges";
          break;
      }
    }
  }
  return "Nem lehetséges";
}

/// How many 5's are needed to get to a specific avarage
/// Parameters:
///
/// ```dart
/// getWithFivesOnly(jegyekÖsszege,jegyekSzáma,elAkarÉrni)
/// ```
String getWithFivesOnly(num jegyek, jsz, elak) {
  //JEGYEK = "Jegyeid összege"
  //JSZ = "Jegyeid száma"
  //ELAK = "Milyen átlagot szeretnél elérni"
  num avarage = jegyek / jsz;
  int index = 0;
  if (avarage > elak) {
    return "Nem lehetséges ötösökkel";
  }
  while (avarage < elak) {
    jsz++;
    jegyek += 5;
    index++;
    avarage = jegyek / jsz;
  }
  return "$index db ötös";
}
