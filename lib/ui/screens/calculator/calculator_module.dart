import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/calculator/whatIf_module.dart' as whatIf;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'calculator_tab.dart' as calcTab;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as stats;

double elakErni = 5.0;
double turesHatar = 1;
String text1 = "";

class CalculatorModule extends StatefulWidget {
  CalculatorModule(this.setStateCallback);
  final Function setStateCallback;

  @override
  _CalculatorModuleState createState() => _CalculatorModuleState();
}

class _CalculatorModuleState extends State<CalculatorModule> {
  @override
  Widget build(BuildContext context) {
    if (marksPage.allParsedByDate.length == 0) {
      return calcTab.noMarks();
    } else {
      return ListView(
        children: <Widget>[
          Center(
            child: Container(
              child: DropdownButton<String>(
                value: calcTab.dropdownValue,
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  color: Theme.of(context).accentColor,
                  height: 2,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    calcTab.dropdownValue = newValue;
                    calcTab.currentIndex =
                        calcTab.dropdownValues.indexOf(newValue);
                    calcTab.currentSubject =
                        stats.allParsedSubjects[calcTab.currentIndex];
                    calcTab.currCount =
                        calcTab.averageList[calcTab.currentIndex].count;
                    calcTab.currSum =
                        calcTab.averageList[calcTab.currentIndex].sum;
                  });
                  widget.setStateCallback();
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
          ),
          Text(
              "${getTranslatedString("marksSumWeighted")}: " +
                  calcTab.currSum.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.division),
          Text(
              "${getTranslatedString("marksCountWeighted")}: " +
                  calcTab.currCount.toString(),
              textAlign: TextAlign.center),
          Icon(MdiIcons.equal),
          Text(
              "${getTranslatedString("yourAv")}: " +
                  (calcTab.currSum / calcTab.currCount).toStringAsFixed(3),
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

  void reCalculate() {
    //text1 = getEasiest(calcTab.currSum, calcTab.currCount, turesHatar, elakErni);
    if (text1 != getTranslatedString("notPos")) {
      text1 = "${getTranslatedString("getAbout")}: " + text1;
    }
  }
}
