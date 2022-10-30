import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/delay.dart';
import 'calculator_tab.dart' as calcTab;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

TextEditingController weightController = TextEditingController(text: "100");
TextEditingController countController = TextEditingController(text: "1");
final FocusNode _weightFocus = FocusNode();
final FocusNode _countFocus = FocusNode();
int radioGroup = 5;
List<VirtualMarks> virtualMarks = [];

Color afterAvCol = Colors.orange;
String afterAvDiff = "0";
Widget afterAvIcon = Icon(
  Icons.linear_scale,
  color: Colors.orange,
);

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

List<LinearMarkChartData> secondaryChartData = [];
double tantargyiAtlagUtanna = 0;

class FormKey {
  static final formKey = GlobalKey<FormState>();
}

class VirtualMarks {
  int count;
  int szamErtek;
  int weight;
}

class WhatIFModule extends StatefulWidget {
  WhatIFModule(this.setStateCallback);

  final Function setStateCallback;

  @override
  _WhatIFModuleState createState() => _WhatIFModuleState();
}

class _WhatIFModuleState extends State<WhatIFModule> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createWhatIfChartAndMarks(
        setAvAfter,
        defaultValues: calcTab.currentSubject,
        id: "whatIfChart",
        virtualValues: virtualMarks,
      );
    });
    super.initState();
  }

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
                                  if (isEditing) {
                                    VirtualMarks temp = new VirtualMarks();
                                    temp.count =
                                        int.parse(countController.text);
                                    temp.weight =
                                        int.parse(weightController.text);
                                    temp.szamErtek = radioGroup;
                                    editVirtualMark(input: temp, index: index);
                                  } else {
                                    VirtualMarks temp = new VirtualMarks();
                                    temp.count =
                                        int.parse(countController.text);
                                    temp.weight =
                                        int.parse(weightController.text);
                                    temp.szamErtek = radioGroup;
                                    addNewVirtualMark(temp);
                                  }
                                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _whatIfBody(),
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
      setAvAfter,
      defaultValues: calcTab.currentSubject,
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
      setAvAfter,
      defaultValues: calcTab.currentSubject,
      id: "whatIfChart",
      virtualValues: virtualMarks,
    );
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
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                child: DropdownButton<String>(
                  value: calcTab.dropdownValue,
                  icon: Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 2,
                  ),
                  onChanged: (String newValue) async {
                    setState(() {
                      calcTab.dropdownValue = newValue;
                      calcTab.currentIndex =
                          calcTab.dropdownValues.indexOf(newValue);
                      calcTab.currentSubject = stats.allParsedSubjects[
                          calcTab.currentIndex]; //INDEX 0 = OLDEST
                      calcTab.currCount =
                          calcTab.averageList[calcTab.currentIndex].count;
                      calcTab.currSum =
                          calcTab.averageList[calcTab.currentIndex].sum;
                    });
                    widget.setStateCallback();
                    createWhatIfChartAndMarks(
                      setAvAfter,
                      defaultValues: calcTab.currentSubject,
                      id: "whatIfChart",
                      virtualValues: virtualMarks,
                    );
                  },
                  items: calcTab.dropdownValues
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
                                setAvAfter,
                                defaultValues: calcTab.currentSubject,
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
                          startActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.5,
                            children: <Widget>[
                              SlidableAction(
                                autoClose: false,
                                label: '-1',
                                backgroundColor: virtualMarks[index].count > 1
                                    ? Colors.blue
                                    : Colors.grey,
                                icon: MdiIcons.minus,
                                onPressed: (context) {
                                  if (virtualMarks[index].count > 1) {
                                    setState(() {
                                      virtualMarks[index].count -= 1;
                                    });
                                    createWhatIfChartAndMarks(
                                      setAvAfter,
                                      defaultValues: calcTab.currentSubject,
                                      id: "whatIfChart",
                                      virtualValues: virtualMarks,
                                    );
                                  }
                                },
                              ),
                              SlidableAction(
                                label: '+1',
                                backgroundColor: virtualMarks[index].count < 100
                                    ? Colors.red
                                    : Colors.grey,
                                autoClose: false,
                                icon: MdiIcons.plus,
                                onPressed: (context) {
                                  if (virtualMarks[index].count < 100) {
                                    setState(() {
                                      virtualMarks[index].count += 1;
                                    });
                                    createWhatIfChartAndMarks(
                                      setAvAfter,
                                      defaultValues: calcTab.currentSubject,
                                      id: "whatIfChart",
                                      virtualValues: virtualMarks,
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.5,
                            children: <Widget>[
                              SlidableAction(
                                autoClose: false,
                                label: getTranslatedString("edit"),
                                backgroundColor: Colors.black45,
                                icon: Icons.create,
                                onPressed: (context) async {
                                  await cardModal(
                                    context: context,
                                    isEditing: true,
                                    index: index,
                                  );
                                },
                              ),
                              SlidableAction(
                                autoClose: false,
                                label: getTranslatedString("delete"),
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) async {
                                  await delay(480);
                                  setState(() {
                                    virtualMarks.removeAt(index);
                                  });
                                  createWhatIfChartAndMarks(
                                    setAvAfter,
                                    defaultValues: calcTab.currentSubject,
                                    id: "whatIfChart",
                                    virtualValues: virtualMarks,
                                  );
                                },
                              ),
                            ],
                          ),
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
                  setAvAfter,
                  defaultValues: calcTab.currentSubject,
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
                      calcTab.dropdownValue +
                          " ${getTranslatedString("avBefore")}: " +
                          (calcTab.currSum / calcTab.currCount)
                              .toStringAsFixed(3),
                      textAlign: TextAlign.start,
                      style: new TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          calcTab.dropdownValue +
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
                setAvAfter,
                defaultValues: calcTab.currentSubject,
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

  void setAvAfter(double input) {
    setState(() {
      if (calcTab.currSum / calcTab.currCount == input) {
        afterAvCol = Colors.orange;
        afterAvDiff = "0";
        afterAvIcon = Icon(
          Icons.linear_scale,
          color: Colors.orange,
        );
      } else if (calcTab.currSum / calcTab.currCount > input) {
        afterAvCol = Colors.red;
        afterAvDiff =
            (input - calcTab.currSum / calcTab.currCount).toStringAsFixed(3);
        afterAvIcon = Icon(
          Icons.keyboard_arrow_down,
          color: Colors.red,
        );
      } else {
        afterAvCol = Colors.green;
        afterAvDiff =
            (input - calcTab.currSum / calcTab.currCount).toStringAsFixed(3);
        afterAvIcon = Icon(
          Icons.keyboard_arrow_up,
          color: Colors.green,
        );
      }
      tantargyiAtlagUtanna = input;
    });
  }
}

List<charts.Series<LinearMarkChartData, int>> createWhatIfChartAndMarks(
    Function(double) setAvAfter,
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
