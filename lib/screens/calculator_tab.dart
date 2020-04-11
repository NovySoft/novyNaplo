import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:flutter_slidable/flutter_slidable.dart';

List<String> dropdownValues = [];
String dropdownValue = dropdownValues[0];
List<CalculatorData> avarageList = [];
var currentIndex = 0;
num currCount;
num currSum;
double elakErni = 5.0;
double turesHatar = 1;
String text1 = " ";
String text2 = " ";
TabController _tabController;
final List<Tab> calcTabs = <Tab>[
  Tab(text: 'Jegyszámoló', icon: Icon(MdiIcons.calculator)),
  Tab(text: 'Mi van ha?', icon: Icon(MdiIcons.headQuestion)),
];
List<VirtualMarks> virtualMarks = [];
int radioGroup = 5;
TextEditingController weightController = TextEditingController();
TextEditingController countController = TextEditingController();

class VirtualMarks {
  int count;
  int numberValue;
  int percentage;
}

class CalculatorTab extends StatefulWidget {
  static String tag = 'calculator';
  static const title = 'Jegyszámoló';

  @override
  CalculatorTabState createState() => CalculatorTabState();
}

class CalculatorTabState extends State<CalculatorTab>
    with SingleTickerProviderStateMixin {
  Widget noMarks() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonSadOutline,
        size: 50,
      ),
      Text(
        "Nincs még jegyed!",
        textAlign: TextAlign.center,
      )
    ]));
  }

  @override
  void initState() {
    //Set dropdown to item 0
    if (globals.markCount != 0) {
      dropdownValue = dropdownValues[0];
      currentIndex = 0;
      currCount = avarageList[0].count;
      currSum = avarageList[0].sum;
    }
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: getDrawer(CalculatorTab.tag, context),
      appBar: AppBar(
        title: Text(CalculatorTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: calcTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: calcTabs.map((Tab tab) {
            if (globals.markCount == 0) {
              return noMarks();
            }
            if (tab.text == "Jegyszámoló") {
              return _calculatorBody();
            } else {
              return Scaffold(
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    onPressed: () {
                      radioGroup = 5;
                      onActionButtonPressed(context);
                    },
                    backgroundColor:
                        DynamicTheme.of(context).brightness == Brightness.dark
                            ? Colors.orange
                            : Colors.lightBlueAccent,
                    child: Icon(MdiIcons.plus),
                    tooltip: "Virtuális jegy hozzáadása",
                    elevation: 10,
                  ),
                  globals.adsEnabled
                      ? SizedBox(
                          height: 90,
                        )
                      : SizedBox(
                          height: 0,
                        ),
                ]),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
                body: _whatIfBody(),
              );
            }
          }).toList()),
    );
  }

  void onActionButtonPressed(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('Új jegy hozzáadása:'),
            content: SizedBox(
              height: 400,
              width: 400,
              child: ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 5,
                        groupValue: radioGroup,
                        onChanged: (index) {
                          setState(() {
                            radioGroup = index;
                          });
                          print(index);
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("5-ös")
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 4,
                        groupValue: radioGroup,
                        onChanged: (index) {
                          setState(() {
                            radioGroup = index;
                          });
                          print(index);
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("4-es")
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 3,
                        groupValue: radioGroup,
                        onChanged: (index) {
                          setState(() {
                            radioGroup = index;
                          });
                          print(index);
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("3-as")
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 2,
                        groupValue: radioGroup,
                        onChanged: (index) {
                          setState(() {
                            radioGroup = index;
                          });
                          print(index);
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("2-es")
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Radio(
                        value: 1,
                        groupValue: radioGroup,
                        onChanged: (index) {
                          setState(() {
                            radioGroup = index;
                          });
                          print(index);
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Text("1-es")
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                            controller: weightController,
                            initialValue: "100",
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "Súlyozás",
                              icon: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Icon(MdiIcons.brightnessPercent)
                                ],
                              ),
                            )),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "%",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 200,
                        child: TextFormField(
                            controller: countController,
                            initialValue: "1",
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "Darab",
                              icon: Column(
                                children: [
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Icon(MdiIcons.counter)
                                ],
                              ),
                            )),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "db",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Mégse'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget _whatIfBody() {
    return Center(
      child: ListView(
        children: <Widget>[
          Text(
            "Mi van ha kapok",
            style: TextStyle(fontSize: 21),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                  items: dropdownValues
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                alignment: Alignment(0, 0),
                margin: EdgeInsets.all(5),
              ),
              Text(
                "-ból/ből",
                style: TextStyle(fontSize: 21),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            "Húzd el a kártyákat az akciókhoz\nVagy a plusz gombbal adj hozzá kártyákat",
            textAlign: TextAlign.center,
          ),
          DecoratedBox(
              decoration: new BoxDecoration(border: Border.all()),
              child: SizedBox(
                height: 400,
                child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: virtualMarks.length,
                    itemBuilder: (context, index) {
                      return Slidable(
                        actionPane: SlidableBehindActionPane(),
                        actionExtentRatio: 0.25,
                        child: Container(
                          color: Colors.grey, //COLOR OF CARD
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigoAccent,
                              child: Text('1DB'),
                              foregroundColor: Colors.black, //TEXT COLOR
                            ),
                            title: Text(
                              '5ös',
                              style: TextStyle(fontSize: 17),
                            ),
                            subtitle: Text('200%'),
                          ),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            closeOnTap: false,
                            caption: '-1',
                            color: Colors.blue,
                            icon: MdiIcons.minus,
                            onTap: () => print("igen"),
                          ),
                          IconSlideAction(
                            closeOnTap: false,
                            caption: '+1',
                            color: Colors.red,
                            icon: MdiIcons.plus,
                            onTap: () => print("igen"),
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Szerkesztés',
                            color: Colors.black45,
                            icon: Icons.create,
                            onTap: () => print("igen"),
                          ),
                          IconSlideAction(
                            caption: 'Törlés',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () => print("igen"),
                          ),
                        ],
                      );
                    }),
              )),
        ],
      ),
    );
  }

  Widget _calculatorBody() {
    if (globals.markCount == 0) {
      return noMarks();
    } else {
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
              items:
                  dropdownValues.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            alignment: Alignment(0, 0),
            margin: EdgeInsets.all(5),
          ),
          Text("Jegyek összege (súlyozva): " + currSum.toString()),
          Icon(MdiIcons.division),
          Text("Jegyek száma (súlyozva): " + currCount.toString()),
          Icon(MdiIcons.equal),
          Text("Átlagod: " + (currSum / currCount).toStringAsFixed(3)),
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
          SizedBox(
            height: 50,
          ),
          Text(
            text1,
            style: TextStyle(fontSize: 20),
          ),
        ],
      );
    }
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
          return "$t db négyest és $n db ötöst";
          break;
        default:
          return "Nem lehetséges";
          break;
      }
    }
  }
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
