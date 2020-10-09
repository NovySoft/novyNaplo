import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'dart:convert';

List<Absence> allParsedAbsences = [];
List<charts.Series> seriesList;
AbsencesBarChartLegendSelection legendSelection =
    new AbsencesBarChartLegendSelection();
var listener;

//TODO: Notification payload
class AbsencesTab extends StatefulWidget {
  @override
  _AbsencesTabState createState() => _AbsencesTabState();
}

class _AbsencesTabState extends State<AbsencesTab>
    with SingleTickerProviderStateMixin {
  List<Absence> tempAbsences = [];

  @override
  void initState() {
    tempAbsences = List.from(allParsedAbsences);
    //tempAbsences = jsonDecode(jsonEncode(allParsedAbsences));
    listener = () async {
      setState(() {
        legendSelection = legendSelection;
      });
      Future.delayed(Duration(milliseconds: 500), () {
        tempAbsences = List.from(allParsedAbsences);
        if (!legendSelection.igazolando) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "BeJustified");
        }
        if (!legendSelection.igazolatlan) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "UnJustified");
        }
        if (!legendSelection.igazolt) {
          tempAbsences.removeWhere(
              (element) => element.justificationState == "Justified");
        }
        setState(() {
          legendSelection = legendSelection;
        });
      });
    };
    legendSelection.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    legendSelection.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext build) {
    // ignore: unused_local_variable
    int _index = 0;
    List<String> hiddenSeries = [];
    if (!legendSelection.igazolando) {
      hiddenSeries.add(getTranslatedString("BeJustified"));
    }
    if (!legendSelection.igazolatlan) {
      hiddenSeries.add(getTranslatedString("UnJustified"));
    }
    if (!legendSelection.igazolt) {
      hiddenSeries.add(getTranslatedString("Justified"));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(capitalize(getTranslatedString("absencesAndDelays"))),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: AbsencesBarChart(
              defaultHiddenSeries: hiddenSeries,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: tempAbsences.length + globals.adModifier,
            itemBuilder: (context, index) {
              if (index >= tempAbsences.length) {
                return SizedBox(
                  height: 100,
                );
              }
              //TODO: Fix fade in
              double opacity = 1;
              Color color = Colors.purple;
              if (tempAbsences[index].justificationState == "BeJustified") {
                color = Colors.yellow;
                opacity = legendSelection.igazolando ? 1 : 0;
              } else if (tempAbsences[index].justificationState ==
                  "UnJustified") {
                color = Colors.red;
                opacity = legendSelection.igazolatlan ? 1 : 0;
              } else if (tempAbsences[index].justificationState ==
                  "Justified") {
                color = Colors.green;
                opacity = legendSelection.igazolt ? 1 : 0;
              }
              return AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: opacity,
                child: AnimatedTitleSubtitleCard(
                  heroAnimation: AlwaysStoppedAnimation(0),
                  color: color,
                  title: "Alma",
                  subTitle: "Körte",
                  onPressed: Text("Alma"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
