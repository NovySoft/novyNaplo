import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/chartHelper.dart';
import 'package:novynaplo/translations/translationProvider.dart';

List<Absence> absencesList = [];
List<charts.Series> seriesList;

class AbsencesTab extends StatelessWidget {
  @override
  Widget build(BuildContext build) {
    return Scaffold(
        appBar: AppBar(
          title: Text(capitalize(getTranslatedString("absences"))),
        ),
        body: SizedBox(
          height: 200,
          width: double.infinity,
          child: AbsencesBarChart(),
        ));
  }
}
