import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/calculator.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/logicAndMath/getAllSubjectsAv.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/Drawer.dart';

//Fixme: This is garbage, REFACTOR when updgrading to mark calc V2
//TODO: Add option to add mark calculator marks to what if
//TODO: add performance to mark calculator and also make averages a before and after gauge pair
List<String> dropdownValues = [];
String dropdownValue = dropdownValues[0];
List<CalculatorData> averageList = [];
var currentIndex = 0;
num currCount;
num currSum;
double elakErni = 5.0;
double turesHatar = 1;
String text1 = " ";
String text2 = " ";
double tantargyiAtlagUtanna = 0;
TabController _tabController;
final List<Tab> calcTabs = <Tab>[
  Tab(text: getTranslatedString("markCalc"), icon: Icon(MdiIcons.calculator)),
  Tab(
      text: "${getTranslatedString("whatIf")}?",
      icon: Icon(MdiIcons.headQuestion)),
];
List<VirtualMarks> virtualMarks = [];
int radioGroup = 5;
TextEditingController weightController = TextEditingController(text: "100");
TextEditingController countController = TextEditingController(text: "1");
final FocusNode _weightFocus = FocusNode();
final FocusNode _countFocus = FocusNode();
final SlidableController slidableController = SlidableController();
List<Evals> currentSubject = [];
List<LinearMarkChartData> secondaryChartData = [];
final axis = charts.NumericAxisSpec(
    renderSpec: charts.GridlineRendererSpec(
        labelStyle: charts.TextStyleSpec(
  fontSize: 10,
  color: charts.MaterialPalette.blue.shadeDefault,
)));

final axisTwo = charts.NumericAxisSpec(
    renderSpec: charts.SmallTickRendererSpec(
  labelStyle: charts.TextStyleSpec(
      fontSize: 10, color: charts.MaterialPalette.blue.shadeDefault),
));
Color afterAvCol = Colors.orange;
String afterAvDiff = "0";
Widget afterAvIcon = Icon(
  Icons.linear_scale,
  color: Colors.orange,
);

class FormKey {
  static final formKey = GlobalKey<FormState>();
}

class VirtualMarks {
  int count;
  int szamErtek;
  int weight;
}

class CalculatorTab extends StatefulWidget {
  static String tag = 'calculator';
  static String title = getTranslatedString("markCalc");

  @override
  CalculatorTabState createState() => CalculatorTabState();
}

class CalculatorTabState extends State<CalculatorTab>
    with SingleTickerProviderStateMixin {
  Future<void> cardModal(
      {BuildContext context, bool isEditing, int index}) async {
    if (isEditing) {
      weightController.text = virtualMarks[index].weight.toString();
      countController.text = virtualMarks[index].count.toString();
      radioGroup = virtualMarks[index].szamErtek;
    } else {
      weightController.text = "100";
      countController.text = "1";
      radioGroup = 5;
    }
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            elevation: globals.darker ? 0 : 24,
            title: Text(isEditing
                ? getTranslatedString("editMark")
                : '${getTranslatedString("addMark")}:'),
            content: SizedBox(
                height: 400,
                width: 400,
                child: Form(
                  key: FormKey.formKey,
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
                            },
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text("5")
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
                            },
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text("4")
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
                            },
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text("3")
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
                            },
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text("2")
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
                            },
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 15,
                              ),
                              Text("1")
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
                              focusNode: _weightFocus,
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslatedString("cantLeaveEmpty");
                                }
                                if (value.length > 6) {
                                  return getTranslatedString(
                                    "mustBeBeetween1and1000",
                                  );
                                }
                                if (int.parse(value) > 1000 ||
                                    int.parse(value) <= 0) {
                                  return getTranslatedString(
                                    "mustBeBeetween1and1000",
                                  );
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: getTranslatedString("weighting"),
                                icon: Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Icon(MdiIcons.brightnessPercent)
                                  ],
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (String input) {
                                if (FormKey.formKey.currentState.validate()) {
                                  _weightFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_countFocus);
                                }
                              },
                            ),
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
                              focusNode: _countFocus,
                              controller: countController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslatedString("cantLeaveEmpty");
                                }
                                if (value.length > 6) {
                                  return getTranslatedString(
                                    "mustBeBeetween1and100",
                                  );
                                }
                                if (int.parse(value) > 100 ||
                                    int.parse(value) <= 0) {
                                  return getTranslatedString(
                                      "mustBeBeetween1and100");
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: getTranslatedString("pcs"),
                                icon: Column(
                                  children: [
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Icon(MdiIcons.counter)
                                  ],
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (String input) {
                                if (FormKey.formKey.currentState.validate()) {
                                  _countFocus.unfocus();
                                }
                              },
                            ),
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                getTranslatedString("count"),
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                )),
            actions: <Widget>[
              TextButton(
                child: Text(getTranslatedString("cancel")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Ok'),
                onPressed: () {
                  if (FormKey.formKey.currentState.validate()) {
                    if (isEditing) {
                      VirtualMarks temp = new VirtualMarks();
                      temp.count = int.parse(countController.text);
                      temp.weight = int.parse(weightController.text);
                      temp.szamErtek = radioGroup;
                      editVirtualMark(input: temp, index: index);
                    } else {
                      VirtualMarks temp = new VirtualMarks();
                      temp.count = int.parse(countController.text);
                      temp.weight = int.parse(weightController.text);
                      temp.szamErtek = radioGroup;
                      addNewVirtualMark(temp);
                    }
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }

  Widget noMarks() {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(
        MdiIcons.emoticonSadOutline,
        size: 50,
      ),
      Text(
        getTranslatedString("possibleNoMarks"),
        textAlign: TextAlign.center,
      )
    ]));
  }

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown MarkCalculator");
    //Set dropdown to item 0
    if (marksPage.allParsedByDate.length != 0) {
      dropdownValue = dropdownValues[0];
      currentIndex = 0;
      currCount = averageList[0].count;
      currSum = averageList[0].sum;
      currentSubject = stats.allParsedSubjects[0];
    }
    getAllSubjectsAv(stats.allParsedSubjects);
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: GlobalDrawer.getDrawer(CalculatorTab.tag, context),
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
            if (marksPage.allParsedByDate.length == 0) {
              return noMarks();
            }
            if (tab.text == getTranslatedString("markCalc")) {
              return _calculatorBody();
            } else {
              return Scaffold(
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    onPressed: () {
                      cardModal(context: context, isEditing: false);
                    },
                    child: Icon(MdiIcons.plus),
                    tooltip: getTranslatedString("addVmark"),
                    elevation: 10,
                  ),
                  SizedBox(
                    height: 15,
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

  //If we have a same mark, then just increase the count
  void addNewVirtualMark(VirtualMarks input) {
    if (globals.shouldVirtualMarksCollapse) {
      int existIndex = virtualMarks.indexWhere((n) {
        return n == input ||
            (n.szamErtek == input.szamErtek && n.weight == input.weight);
      });
      if (existIndex == -1 || virtualMarks[existIndex].count == 100) {
        existIndex = virtualMarks.lastIndexWhere((n) {
          return n == input ||
              (n.szamErtek == input.szamErtek && n.weight == input.weight);
        });
      }
      if (existIndex == -1 || virtualMarks[existIndex].count >= 100) {
        setState(() {
          virtualMarks.add(input);
        });
      } else if (virtualMarks[existIndex].count + input.count > 100) {
        input.count = (input.count + virtualMarks[existIndex].count) - 100;
        setState(() {
          virtualMarks[existIndex].count = 100;
          virtualMarks.add(input);
        });
      } else {
        setState(() {
          virtualMarks[existIndex].count += input.count;
        });
      }
    } else {
      setState(() {
        virtualMarks.add(input);
      });
    }
    createWhatIfChartAndMarks(
      defaultValues: currentSubject,
      id: "whatIfChart",
      virtualValues: virtualMarks,
    );
  }

  void editVirtualMark({VirtualMarks input, int index}) {
    setState(() {
      virtualMarks[index].weight = input.weight;
      virtualMarks[index].count = input.count;
      virtualMarks[index].szamErtek = input.szamErtek;
    });
    createWhatIfChartAndMarks(
      defaultValues: currentSubject,
      id: "whatIfChart",
      virtualValues: virtualMarks,
    );
  }

  void setAvAfter(double input) {
    setState(() {
      if (currSum / currCount == input) {
        afterAvCol = Colors.orange;
        afterAvDiff = "0";
        afterAvIcon = Icon(
          Icons.linear_scale,
          color: Colors.orange,
        );
      } else if (currSum / currCount > input) {
        afterAvCol = Colors.red;
        afterAvDiff = (input - currSum / currCount).toStringAsFixed(3);
        afterAvIcon = Icon(
          Icons.keyboard_arrow_down,
          color: Colors.red,
        );
      } else {
        afterAvCol = Colors.green;
        afterAvDiff = (input - currSum / currCount).toStringAsFixed(3);
        afterAvIcon = Icon(
          Icons.keyboard_arrow_up,
          color: Colors.green,
        );
      }
      tantargyiAtlagUtanna = input;
    });
  }

  Widget _whatIfBody() {
    return Center(
      child: ListView(
        children: <Widget>[
          Text(
            getTranslatedString("whatIfIGet"),
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
                  onChanged: (String newValue) async {
                    setState(() {
                      dropdownValue = newValue;
                      currentIndex = dropdownValues.indexOf(newValue);
                      currentSubject = stats
                          .allParsedSubjects[currentIndex]; //INDEX 0 = OLDEST
                      currCount = averageList[currentIndex].count;
                      currSum = averageList[currentIndex].sum;
                    });
                    createWhatIfChartAndMarks(
                      defaultValues: currentSubject,
                      id: "whatIfChart",
                      virtualValues: virtualMarks,
                    );
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
                getTranslatedString("bolbol"),
                style: TextStyle(fontSize: 21),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          DecoratedBox(
            decoration: new BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                left: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                right: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
                bottom: BorderSide(
                  width: 1.0,
                  color: globals.darker ? Colors.white : Colors.black,
                ),
              ),
            ),
            child: SizedBox(
              height: 250,
              child: virtualMarks.length != 0
                  ? ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: virtualMarks.length,
                      itemBuilder: (context, index) {
                        String countText = "";
                        String numVal = "";
                        Color numValColor = Colors.green;
                        if (virtualMarks[index].count > 9) {
                          countText = virtualMarks[index].count.toString();
                        } else {
                          countText = virtualMarks[index].count.toString() +
                              getTranslatedString("count");
                        }
                        switch (virtualMarks[index].szamErtek) {
                          case 1:
                            numVal = "1";
                            numValColor = Colors.red[900];
                            break;
                          case 2:
                            numVal = "2";
                            numValColor = Colors.red[400];
                            break;
                          case 3:
                            numVal = "3";
                            numValColor = Colors.orange;
                            break;
                          case 4:
                            numVal = "4";
                            numValColor = Colors.lightGreen;
                            break;
                          case 5:
                            numVal = "5";
                            numValColor = Colors.green;
                            break;
                          default:
                        }
                        return Slidable(
                          controller: slidableController,
                          actionPane: SlidableBehindActionPane(),
                          actionExtentRatio: 0.25,
                          child: GestureDetector(
                            onLongPress: () async {
                              await cardModal(
                                context: context,
                                isEditing: true,
                                index: index,
                              );
                            },
                            onDoubleTap: () async {
                              setState(() {
                                virtualMarks.removeAt(index);
                              });
                              createWhatIfChartAndMarks(
                                defaultValues: currentSubject,
                                id: "whatIfChart",
                                virtualValues: virtualMarks,
                              );
                            },
                            child: Container(
                              color: numValColor, //COLOR OF CARD
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigoAccent,
                                  child: Text(countText),
                                  foregroundColor: Colors.black, //TEXT COLOR
                                ),
                                title: Text(
                                  numVal,
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black),
                                ),
                                subtitle: Text(
                                    virtualMarks[index].weight.toString() +
                                        "%"),
                              ),
                            ),
                          ),
                          actions: <Widget>[
                            IconSlideAction(
                              closeOnTap: false,
                              caption: '-1',
                              color: virtualMarks[index].count > 1
                                  ? Colors.blue
                                  : Colors.grey,
                              icon: MdiIcons.minus,
                              onTap: () {
                                if (virtualMarks[index].count > 1) {
                                  setState(() {
                                    virtualMarks[index].count -= 1;
                                  });
                                  createWhatIfChartAndMarks(
                                    defaultValues: currentSubject,
                                    id: "whatIfChart",
                                    virtualValues: virtualMarks,
                                  );
                                }
                              },
                            ),
                            IconSlideAction(
                              closeOnTap: false,
                              caption: '+1',
                              color: virtualMarks[index].count < 100
                                  ? Colors.red
                                  : Colors.grey,
                              icon: MdiIcons.plus,
                              onTap: () {
                                if (virtualMarks[index].count < 100) {
                                  setState(() {
                                    virtualMarks[index].count += 1;
                                  });
                                  createWhatIfChartAndMarks(
                                    defaultValues: currentSubject,
                                    id: "whatIfChart",
                                    virtualValues: virtualMarks,
                                  );
                                }
                              },
                            ),
                          ],
                          secondaryActions: <Widget>[
                            IconSlideAction(
                              caption: getTranslatedString("edit"),
                              color: Colors.black45,
                              icon: Icons.create,
                              onTap: () async {
                                await cardModal(
                                  context: context,
                                  isEditing: true,
                                  index: index,
                                );
                              },
                            ),
                            IconSlideAction(
                              caption: getTranslatedString("delete"),
                              color: Colors.red,
                              icon: Icons.delete,
                              onTap: () async {
                                await delay(480);
                                setState(() {
                                  virtualMarks.removeAt(index);
                                });
                                createWhatIfChartAndMarks(
                                  defaultValues: currentSubject,
                                  id: "whatIfChart",
                                  virtualValues: virtualMarks,
                                );
                              },
                            ),
                          ],
                        );
                      })
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            MdiIcons.emoticonSadOutline,
                            size: 50,
                          ),
                          Text(
                            getTranslatedString("noVmark"),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            getTranslatedString("addSomeVmark"),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            getTranslatedString("VmarkSlide"),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
            ),
          ),
          Center(
            child: ElevatedButton.icon(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              onPressed: () async {
                setState(() {
                  virtualMarks = [];
                });
                createWhatIfChartAndMarks(
                  defaultValues: currentSubject,
                  id: "whatIfChart",
                  virtualValues: virtualMarks,
                );
              },
              icon: Icon(
                MdiIcons.delete,
              ),
              label: Text(
                getTranslatedString("delAll"),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dropdownValue +
                          " ${getTranslatedString("avBefore")}: " +
                          (currSum / currCount).toStringAsFixed(3),
                      textAlign: TextAlign.start,
                      style: new TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          dropdownValue +
                              " ${getTranslatedString("avAfter")}: " +
                              tantargyiAtlagUtanna.toStringAsFixed(3),
                          textAlign: TextAlign.start,
                          style: new TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        afterAvIcon,
                        Text(
                          afterAvDiff,
                          style: TextStyle(color: afterAvCol),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 500,
            child: new charts.NumericComboChart(
              createWhatIfChartAndMarks(
                defaultValues: currentSubject,
                id: "whatIfChart",
                virtualValues: virtualMarks,
              ),
              behaviors: [new charts.PanAndZoomBehavior()],
              animate: false,
              domainAxis: axisTwo,
              primaryMeasureAxis: axis,
              defaultRenderer:
                  new charts.LineRendererConfig(includePoints: true),
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _calculatorBody() {
    if (marksPage.allParsedByDate.length == 0) {
      return noMarks();
    } else {
      return ListView(
        children: <Widget>[
          Center(
            child: Container(
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
                    currentSubject = stats.allParsedSubjects[currentIndex];
                    currCount = averageList[currentIndex].count;
                    currSum = averageList[currentIndex].sum;
                  });
                  createWhatIfChartAndMarks(
                    defaultValues: currentSubject,
                    id: "whatIfChart",
                    virtualValues: virtualMarks,
                  );
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
          ),
          Text(
              "${getTranslatedString("marksSumWeighted")}: " +
                  currSum.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.division),
          Text(
              "${getTranslatedString("marksCountWeighted")}: " +
                  currCount.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.equal),
          Text(
              "${getTranslatedString("yourAv")}: " +
                  (currSum / currCount).toStringAsFixed(3),
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          Text("${getTranslatedString("wantGet")}? $elakErni",
              textAlign: TextAlign.center),
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
          Text("${getTranslatedString("underHowMany")}? $turesHatar",
              textAlign: TextAlign.center),
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
          Row(
            children: [
              SizedBox(
                width: 12,
              ),
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      reCalculate();
                    });
                  },
                  child: Text(
                    getTranslatedString("go"),
                  ),
                ),
              ),
              SizedBox(
                width: 12,
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  text1,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(
            height: 250,
          ),
        ],
      );
    }
  }

  List<charts.Series<LinearMarkChartData, int>> createWhatIfChartAndMarks(
      {List<Evals> defaultValues,
      List<VirtualMarks> virtualValues,
      String id}) {
    List<LinearMarkChartData> primaryChartData = [];
    secondaryChartData = [];
    double sum = 0;
    double index = 0;
    int listArray = 0;
    for (var n in defaultValues) {
      sum += n.numberValue * n.weight / 100;
      index += 1 * n.weight / 100;
      primaryChartData.add(new LinearMarkChartData(listArray, sum / index));
      listArray++;
    }
    secondaryChartData.add(new LinearMarkChartData(listArray - 1, sum / index));
    for (var n in virtualValues) {
      for (var i = 0; i < n.count; i++) {
        sum += n.szamErtek * n.weight / 100;
        index += 1 * n.weight / 100;
        secondaryChartData.add(new LinearMarkChartData(listArray, sum / index));
        listArray++;
      }
    }
    setAvAfter(secondaryChartData.last.value);
    return [
      new charts.Series<LinearMarkChartData, int>(
        id: id + "secondary",
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (LinearMarkChartData marks, _) => marks.count,
        measureFn: (LinearMarkChartData marks, _) => marks.value,
        data: secondaryChartData,
      ),
      new charts.Series<LinearMarkChartData, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearMarkChartData marks, _) => marks.count,
        measureFn: (LinearMarkChartData marks, _) => marks.value,
        data: primaryChartData,
      )
    ];
  }
}

void reCalculate() {
  text1 = getEasiest(currSum, currCount, turesHatar, elakErni);
  if (text1 != getTranslatedString("notPos")) {
    text1 = "${getTranslatedString("getAbout")}: " + text1;
  }
}

/// Get the easiest way to get to a specific average
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
      return "1 ${getTranslatedString("count")} $elak";
    }
  }

  var atlag = jegyek / jsz; //átlag
  var x = elak * jsz +
      elak * th -
      jegyek; //mennyi jegyet kell hozzáadni, hogy elérjük az adott átlagot

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
      return getTranslatedString("notPos");
    } else {
      switch (w) {
        case 1:
          while (t + n * 2 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("twos")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("ones")}";
          break;
        case 2:
          while (t * 2 + n * 3 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("threes")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("twos")}";
          break;
        case 3:
          while (t * 3 + n * 4 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("threes")}";
          break;
        case 4:
          while (t * 4 + n * 5 != x) {
            t = t - 1;
            n = n + 1;
          }
          return "$t ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $n ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        case 5:
          return "$th ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        default:
          return getTranslatedString("notPos");
          break;
      }
    }
  } else {
    if (j2 - th < 0) {
      return getTranslatedString("notPos");
    } else {
      switch (ww) {
        case 1:
          while (t + n * 2 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("twos")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("ones")}";
          break;
        case 2:
          while (t * 2 + n * 3 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("threes")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("twos")}";
          break;
        case 3:
          while (t * 3 + n * 4 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$n ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $t ${getTranslatedString("count")} ${getTranslatedString("threes")}";
          break;
        case 4:
          while (t * 4 + n * 5 != j2) {
            t = t - 1;
            n = n + 1;
          }
          return "$t ${getTranslatedString("count")} ${getTranslatedString("fours")} ${getTranslatedString("and")} $n ${getTranslatedString("count")} ${getTranslatedString("fives")}";
          break;
        default:
          return getTranslatedString("notPos");
          break;
      }
    }
  }
}

/// How many 5's are needed to get to a specific average
/// Parameters:
///
/// ```dart
/// getWithFivesOnly(jegyekÖsszege,jegyekSzáma,elAkarÉrni)
/// ```
String getWithFivesOnly(num jegyek, jsz, elak) {
  //JEGYEK = "Jegyeid összege"
  //JSZ = "Jegyeid száma"
  //ELAK = "Milyen átlagot szeretnél elérni"
  num average = jegyek / jsz;
  int index = 0;
  if (average > elak) {
    return "Nem lehetséges ötösökkel";
  }
  while (average < elak) {
    jsz++;
    jegyek += 5;
    index++;
    average = jegyek / jsz;
  }
  return "$index ${getTranslatedString("count")} ötös";
}
