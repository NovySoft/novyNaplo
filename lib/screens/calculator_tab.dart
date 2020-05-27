import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/screens/statistics_tab.dart' as stats;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/translations/translationProvider.dart';

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
double tantargyiAtlagUtanna = 0;
TabController _tabController;
final List<Tab> calcTabs = <Tab>[
  Tab(text: 'Jegyszámoló', icon: Icon(MdiIcons.calculator)),
  Tab(text: 'Mi van ha?', icon: Icon(MdiIcons.headQuestion)),
];
List<VirtualMarks> virtualMarks = [];
int radioGroup = 5;
TextEditingController weightController = TextEditingController(text: "100");
TextEditingController countController = TextEditingController(text: "1");
final FocusNode _weightFocus = FocusNode();
final FocusNode _countFocus = FocusNode();
final _formKey = GlobalKey<FormState>();
final SlidableController slidableController = SlidableController();
List<Evals> currentSubject = [];
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
Color afterAvCol;
Widget afterAvIcon;
String afterAvDiff;

class VirtualMarks {
  int count;
  int numberValue;
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
      radioGroup = virtualMarks[index].numberValue;
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
            title: Text(isEditing
                ? getTranslatedString("editMark")
                : '${getTranslatedString("addMark")}:'),
            content: SizedBox(
                height: 400,
                width: 400,
                child: Form(
                  key: _formKey,
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
                              focusNode: _weightFocus,
                              controller: weightController,
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslatedString("cantLeaveEmpty");
                                }
                                if (int.parse(value) > 1000 ||
                                    int.parse(value) <= 0) {
                                  return getTranslatedString(
                                      "mustBeBeetween1and1000");
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
                                if (_formKey.currentState.validate()) {
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
                                WhitelistingTextInputFormatter.digitsOnly
                              ],
                              validator: (value) {
                                if (value.isEmpty) {
                                  return getTranslatedString("cantLeaveEmpty");
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
                                if (_formKey.currentState.validate()) {
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
              FlatButton(
                child: Text(getTranslatedString("cancel")),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (isEditing) {
                      VirtualMarks temp = new VirtualMarks();
                      temp.count = int.parse(countController.text);
                      temp.weight = int.parse(weightController.text);
                      temp.numberValue = radioGroup;
                      editVirtualMark(input: temp, index: index);
                    } else {
                      VirtualMarks temp = new VirtualMarks();
                      temp.count = int.parse(countController.text);
                      temp.weight = int.parse(weightController.text);
                      temp.numberValue = radioGroup;
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
    //Set dropdown to item 0
    if (globals.markCount != 0) {
      dropdownValue = dropdownValues[0];
      currentIndex = 0;
      currCount = avarageList[0].count;
      currSum = avarageList[0].sum;
      currentSubject = stats.allParsedSubjects[0];
    }
    getAllSubjectsAv(stats.allParsedSubjects);
    _tabController = new TabController(vsync: this, length: 2);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
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
            if (tab.icon == Icon(MdiIcons.calculator)) {
              return _calculatorBody();
            } else {
              return Scaffold(
                floatingActionButton:
                    Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  FloatingActionButton(
                    onPressed: () {
                      cardModal(context: context, isEditing: false);
                    },
                    backgroundColor:
                        DynamicTheme.of(context).brightness == Brightness.dark
                            ? Colors.orange
                            : Colors.lightBlueAccent,
                    child: Icon(MdiIcons.plus),
                    tooltip: getTranslatedString("addVmark"),
                    elevation: 10,
                  ),
                  globals.adsEnabled
                      ? SizedBox(
                          height: 90,
                        )
                      : SizedBox(
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
            (n.numberValue == input.numberValue && n.weight == input.weight);
      });
      if (existIndex == -1 || virtualMarks[existIndex].count == 100) {
        existIndex = virtualMarks.lastIndexWhere((n) {
          return n == input ||
              (n.numberValue == input.numberValue && n.weight == input.weight);
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
  }

  void editVirtualMark({VirtualMarks input, int index}) {
    setState(() {
      virtualMarks[index].weight = input.weight;
      virtualMarks[index].count = input.count;
      virtualMarks[index].numberValue = input.numberValue;
    });
  }

  void setAvAfter(double input) {
    if (currSum / currCount == input) {
      afterAvCol = Colors.yellow;
      afterAvDiff = "0";
      afterAvIcon = Icon(
        Icons.linear_scale,
        color: Colors.yellow,
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
    setState(() {
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
                getTranslatedString("bolbol"),
                style: TextStyle(fontSize: 21),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          DecoratedBox(
            decoration: new BoxDecoration(border: Border.all()),
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
                        switch (virtualMarks[index].numberValue) {
                          case 1:
                            numVal = "1-es";
                            numValColor = Colors.red[900];
                            break;
                          case 2:
                            numVal = "2-es";
                            numValColor = Colors.red[400];
                            break;
                          case 3:
                            numVal = "3-as";
                            numValColor = Colors.orange;
                            break;
                          case 4:
                            numVal = "4-es";
                            numValColor = Colors.lightGreen;
                            break;
                          case 5:
                            numVal = "5-ös";
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
                                await sleep(480);
                                setState(() {
                                  virtualMarks.removeAt(index);
                                });
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
            child: RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              onPressed: () async {
                setState(() {
                  virtualMarks = [];
                });
              },
              icon: Icon(
                MdiIcons.delete,
                color: Colors.black,
              ),
              label: Text(
                getTranslatedString("delAll"),
                style: TextStyle(color: Colors.black),
              ),
            ),
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
          SizedBox(
            height: 20,
          ),
          Text(
            dropdownValue +
                " ${getTranslatedString("avBefore")}: " +
                (currSum / currCount).toStringAsFixed(3),
            textAlign: TextAlign.start,
            style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                dropdownValue +
                    " ${getTranslatedString("avAfter")}: " +
                    tantargyiAtlagUtanna.toStringAsFixed(3),
                textAlign: TextAlign.start,
                style: new TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              afterAvIcon,
              Text(
                afterAvDiff,
                style: TextStyle(color: afterAvCol),
              )
            ],
          ),
          globals.adsEnabled
              ? SizedBox(
                  height: 150,
                )
              : SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _calculatorBody() {
    if (globals.markCount == 0) {
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
          ),
          Text("${getTranslatedString("marksSumWeighted")}: " + currSum.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.division),
          Text("${getTranslatedString("marksCountWeighted")}: " + currCount.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.equal),
          Text("${getTranslatedString("yourAv")}: " + (currSum / currCount).toStringAsFixed(3),
              textAlign: TextAlign.center),
          SizedBox(height: 20),
          Text("${getTranslatedString("wantGet")}? $elakErni", textAlign: TextAlign.center),
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
              child: Text(getTranslatedString("go"), style: TextStyle(color: Colors.black)),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text(text1,
              style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
          SizedBox(
            height: 250,
          ),
        ],
      );
    }
  }

  List<charts.Series<ChartPoints, int>> createWhatIfChartAndMarks(
      {List<Evals> defaultValues,
      List<VirtualMarks> virtualValues,
      String id}) {
    List<ChartPoints> primaryChartData = [];
    List<ChartPoints> secondaryChartData = [];
    double sum = 0;
    double index = 0;
    double virtualSum = 0;
    double virtualIndex = 0;
    int listArray = 0;
    for (var n in defaultValues) {
      sum += n.numberValue * double.parse(n.weight.split("%")[0]) / 100;
      index += 1 * double.parse(n.weight.split("%")[0]) / 100;
      primaryChartData.add(new ChartPoints(listArray, sum / index));
      listArray++;
    }
    secondaryChartData.add(new ChartPoints(listArray - 1, sum / index));
    for (var n in virtualValues) {
      for (var i = 0; i < n.count; i++) {
        sum += n.numberValue * n.weight / 100;
        virtualSum += n.numberValue * n.weight / 100;
        index += 1 * n.weight / 100;
        virtualIndex += 1 * n.weight / 100;
        secondaryChartData.add(new ChartPoints(listArray, sum / index));
        listArray++;
      }
    }
    //ONLY WORKS WHEN SETSTATE IS OUTSIDE OF THIS FUNCTION
    //STRANGE..
    setAvAfter((currSum + virtualSum) / (currCount + virtualIndex));
    return [
      new charts.Series<ChartPoints, int>(
        id: id + "secondary",
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (ChartPoints marks, _) => marks.count,
        measureFn: (ChartPoints marks, _) => marks.value,
        data: secondaryChartData,
      ),
      new charts.Series<ChartPoints, int>(
        id: id,
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (ChartPoints marks, _) => marks.count,
        measureFn: (ChartPoints marks, _) => marks.value,
        data: primaryChartData,
      )
    ];
  }
}

//TODO translate under this
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
