import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/common.dart' as common;
import 'package:novynaplo/data/models/absence.dart';
import 'package:novynaplo/data/models/chartData.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/global.dart' as globals;

List<charts.Series<AbsenceChartData, String>> createAbsencesChartData(
    List<List<Absence>> input) {
  List<dynamic> inputList = List.from(input).expand((i) => i).toList();
  final delayList = inputList.where((n) => n.type == "Delay");
  int igazolandoDelay = 0, igazoltDelay = 0, igazolatlanDelay = 0;
  if (delayList.length != 0) {
    //Igazolando
    for (var n in delayList
        .where((element) => element.justificationState == "BeJustified")) {
      igazolandoDelay += n.delayTimeMinutes;
    }
    //Igazolt
    for (var n in delayList
        .where((element) => element.justificationState == "Justified")) {
      igazoltDelay += n.delayTimeMinutes;
    }
    //Igazolatlan
    for (var n in delayList
        .where((element) => element.justificationState == "UnJustified")) {
      igazolatlanDelay += n.delayTimeMinutes;
    }
  }

  final igazolando = [
    new AbsenceChartData(
      getTranslatedString("absences"),
      inputList
          .where((n) =>
              n.justificationState == "BeJustified" && n.type == "Absence")
          .length,
    ),
    new AbsenceChartData(
      getTranslatedString("delays"),
      igazolandoDelay,
    ),
  ];

  final igazolt = [
    new AbsenceChartData(
      getTranslatedString("absences"),
      inputList
          .where(
              (n) => n.justificationState == "Justified" && n.type == "Absence")
          .length,
    ),
    new AbsenceChartData(
      getTranslatedString("delays"),
      igazoltDelay,
    ),
  ];

  final igazolatlan = [
    new AbsenceChartData(
      getTranslatedString("absences"),
      inputList
          .where((n) =>
              n.justificationState == "UnJustified" && n.type == "Absence")
          .length,
    ),
    new AbsenceChartData(
      getTranslatedString("delays"),
      igazolatlanDelay,
    ),
  ];

  return [
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("UnJustified"),
      seriesColor: charts.MaterialPalette.red.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.count,
      data: igazolatlan,
    ),
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("BeJustified"),
      seriesColor: charts.MaterialPalette.yellow.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.count,
      data: igazolando,
    ),
    new charts.Series<AbsenceChartData, String>(
      id: getTranslatedString("Justified"),
      seriesColor: charts.MaterialPalette.green.shadeDefault,
      domainFn: (AbsenceChartData sales, _) => sales.name,
      measureFn: (AbsenceChartData sales, _) => sales.count,
      data: igazolt,
    ),
  ];
}

class AbsencesBarChartLegendSelection with ChangeNotifier {
  bool _igazolando = true;
  bool _igazolt = true;
  bool _igazolatlan = true;

  bool get igazolando => _igazolando;
  bool get igazolt => _igazolt;
  bool get igazolatlan => _igazolatlan;

  set igazolando(value) {
    _igazolando = value;
    notifyListeners();
  }

  set igazolt(value) {
    _igazolt = value;
    notifyListeners();
  }

  set igazolatlan(value) {
    _igazolatlan = value;
    notifyListeners();
  }

  @override
  String toString() {
    return """"
    Igazolando: $_igazolando
    Igazolatlan:  $_igazolatlan
    Igazolt: $_igazolt
    """;
  }
}

class AbsencesBarChart extends StatelessWidget {
  final void Function() callback;
  final defaultHiddenSeries;
  final bool reDraw;
  AbsencesBarChart(
      {this.callback, this.defaultHiddenSeries, this.reDraw = false});

  final axis = charts.NumericAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
    fontSize: 10,
    color: charts.MaterialPalette.blue.shadeDefault,
  )));

  final axisTwo = charts.OrdinalAxisSpec(
      renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(
    fontSize: 10,
    color: charts.MaterialPalette.blue.shadeDefault,
  )));

  @override
  Widget build(BuildContext context) {
    var seriesList = createAbsencesChartData(absencesPage.allParsedAbsences);
    return new charts.BarChart(
      seriesList,
      animate: globals.chartAnimations,
      barGroupingType: charts.BarGroupingType.stacked,
      vertical: false,
      primaryMeasureAxis: axis,
      domainAxis: axisTwo,
      selectionModels: [
        new charts.SelectionModelConfig(
          type: charts.SelectionModelType.info,
          updatedListener: _absencesChartSelectUpdated,
        )
      ],
      behaviors: [
        new charts.SeriesLegend.customLayout(
          CustomLegendBuilder(reDraw),
          outsideJustification: charts.OutsideJustification.middle,
          defaultHiddenSeries: defaultHiddenSeries,
        ),
      ],
    );
  }

  void _absencesChartSelectUpdated(charts.SelectionModel<String> model) {
    //open animatedcontainer
    if (model.hasAnySelection) {
      if (callback == null) return;
      callback();
    }
  }
}

class CustomLegendBuilder extends charts.LegendContentBuilder {
  bool reDraw;
  CustomLegendBuilder(this.reDraw);

  /// Convert the charts common TextStlyeSpec into a standard TextStyle.
  TextStyle _convertTextStyle(
      bool isHidden, BuildContext context, common.TextStyleSpec textStyle) {
    return new TextStyle(
        inherit: true,
        fontFamily: textStyle?.fontFamily,
        fontSize: 13,
        color: isHidden
            ? (DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(0.25)
                : Colors.white.withOpacity(0.25))
            : (DynamicTheme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white));
  }

  Widget createLabel(BuildContext context, common.LegendEntry legendEntry,
      common.SeriesLegend legend, bool isHidden) {
    TextStyle style =
        _convertTextStyle(isHidden, context, legendEntry.textStyle);
    Color color =
        charts.ColorUtil.toDartColor(legendEntry.color) ?? Colors.blue;

    return new GestureDetector(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
            ),
            Container(
              height: 15,
              width: 15,
              color: isHidden ? color.withOpacity(0.25) : color,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              legendEntry.label,
              style: style,
            ),
          ],
        ),
        onTapUp: makeTapUpCallback(context, legendEntry, legend));
  }

  GestureTapUpCallback makeTapUpCallback(BuildContext context,
      common.LegendEntry legendEntry, common.SeriesLegend legend) {
    return (TapUpDetails d) {
      switch (legend.legendTapHandling) {
        case common.LegendTapHandling.hide:
          final seriesId = legendEntry.series.id;
          if (legend.isSeriesHidden(seriesId)) {
            // This will not be recomended since it suposed to be accessible only from inside the legend class, but it worked fine on my code.
            switch (legendEntry.series.seriesColor.toString()) {
              case "#4caf50ff":
                absencesPage.legendSelection.igazolt = true;
                break;
              case "#ffeb3bff":
                absencesPage.legendSelection.igazolando = true;
                break;
              case "#f44336ff":
                absencesPage.legendSelection.igazolatlan = true;
                break;
            }
            // ignore: invalid_use_of_protected_member
            legend.showSeries(seriesId);
          } else {
            switch (legendEntry.series.seriesColor.toString()) {
              case "#4caf50ff":
                absencesPage.legendSelection.igazolt = false;
                break;
              case "#ffeb3bff":
                absencesPage.legendSelection.igazolando = false;
                break;
              case "#f44336ff":
                absencesPage.legendSelection.igazolatlan = false;
                break;
            }
            // ignore: invalid_use_of_protected_member
            legend.hideSeries(seriesId);
          }
          if (reDraw) {
            // ignore: invalid_use_of_protected_member
            legend.chart.redraw(skipLayout: true, skipAnimation: false);
          }
          break;
        case common.LegendTapHandling.none:
        default:
          break;
      }
    };
  }

  @override
  Widget build(BuildContext context, common.LegendState legendState,
      common.Legend legend,
      {bool showMeasures}) {
    final entryWidgets = legendState.legendEntries.map((legendEntry) {
      var isHidden = false;
      if (legend is common.SeriesLegend) {
        isHidden = legend.isSeriesHidden(legendEntry.series.id);
      }
      return createLabel(
          context, legendEntry, legend as common.SeriesLegend, isHidden);
    }).toList();

    return Wrap(
      clipBehavior: Clip.antiAlias,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: entryWidgets,
      spacing: 15,
      runSpacing: 15,
    );
  }
}
