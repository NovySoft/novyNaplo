import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';

List<String> dropdownValues = [""];
String dropdownValue = dropdownValues[0];
List<CalculatorData> avarageList;
var currentIndex = 0;
var currCount = 0;
var currSum; //TODO Extend to non 100% marks
double elakErni = 5.0;
double turesHatar = 1;
String text1 = " ";
String text2 = " ";

class CalculatorTab extends StatefulWidget {
  static String tag = 'calculator';
  static const title = 'Jegyszámoló';

  @override
  CalculatorTabState createState() => CalculatorTabState();
}

class CalculatorTabState extends State<CalculatorTab> {
  @override
  void initState() {
    super.initState();
    //Set dropdown to item 0
    dropdownValue = dropdownValues[0];
    currentIndex = dropdownValues.indexOf(dropdownValue);
    currCount = avarageList[currentIndex].count;
    currSum = avarageList[currentIndex].sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(CalculatorTab.tag, context),
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
                currCount = avarageList[currentIndex].count;
                currSum = avarageList[currentIndex].sum;
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
        Text("Jegyek száma: " + currCount.toString()),
        Text("Jegyek összege: " + currSum.toString()),
        Text("Átlagod: " + (currSum / currCount).toString()),
        SizedBox(height: 20),
        Text("Mit szeretnél elérni? $elakErni"),
        Slider(
          value: elakErni,
          onChanged: (newValue) {
            setState(() {
              elakErni = newValue;
            });
          },
          min: 1,
          max: 5,
          divisions: 40,
          label: elakErni.toString(),
        ),
        Text("Hány jegy alatt szeretnéd elérni? $turesHatar"),
        Slider(
          value: turesHatar,
          onChanged: (newValue) {
            setState(() {
              turesHatar = newValue.roundToDouble();
            });
          },
          min: 1,
          max: 10,
          divisions: 10,
          label: turesHatar.toString(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 1.0),
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onPressed: () {
              setState(() {
                reCalculate();
              });
            },
            padding: EdgeInsets.all(12),
            child: Text('Mehet', style: TextStyle(color: Colors.black)),
          ),
        ),
        SizedBox(height: 50,),
        Text(
          text1,
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }
}

void reCalculate() {
  text1 = getEasiest(currSum, currCount, turesHatar, elakErni);
  if (text1 != "Nem lehetséges") {
    text1 = "Szerezz kb.: " + text1;
  }
}

/// Get the easiest way to get to a specific avarage
/// Parameters:
///
/// ```dart
/// getEasiest(jegyekÖsszege,jegyekSzáma,mennyiJegyAlattt,elAkarÉrni)
/// ```
String getEasiest(num jegyek, jsz, th, elak) {
  bool isInteger(num value) => value is int || value == value.roundToDouble();
  //jegyek = "jegyeid összege"
  //jsz = "jegyeid száma"
  //th = "mennyi jegy alatt akarod elérni?"
  //elak = "milyen átlagot akarsz elérni?"

  if (jsz == 0 || jegyek == 0) {
    if (isInteger(elak)) {
      return "1 db $elak";
    }
  }

  var atlag = jegyek / jsz; //átlag
  var x = elak * jsz +
      elak * th -
      jegyek; //mennyi jegyet kell hozzáadni, hogy elérjük az adottátlagot

  var j2 = th *
      5; // rontásnál mennyi jegyet kell hozzáadni, hogy elérjük az adottátlagot
  var j1 = jegyek + j2 / jsz + th; // az átlag amit a rontásnál számolunk

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
  num c = x / th;
  num cc = j2 / th;

  int ww = cc.toInt();
  int w = c.toInt();
  if (elak >= atlag) {
    if (x - 5 * th > 0) {
      print(1);
      return "Nem lehetséges";
    } else {
      switch (w) {
        case 1:
          while (t + n * 2 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db kettest és $t db egyest";
          break;
        case 2:
          while (t * 2 + n * 3 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db hármast és $t db kettest";
          break;
        case 3:
          while (t * 3 + n * 4 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyest és $t db hármast";
          break;
        case 4:
          while (t * 4 + n * 5 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$t db négyest és $n db ötöst";
          break;
        case 5:
          return "$th db ötöst";
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
          return "$n db kettest és $t db egyest";
          break;
        case 2:
          while (t * 2 + n * 3 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db hármast és $t db kettest";
          break;
        case 3:
          while (t * 3 + n * 4 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyest és $t db hármast";
          break;
        case 4:
          while (t * 4 + n * 5 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n db négyest és $t db ötöst";
          break;
        default:
          return "Nem lehetséges";
          break;
      }
    }
  }
  return "Dead code";
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
