import 'package:test/test.dart' as test;
import 'package:flutter_test/flutter_test.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/main.dart';
import 'package:novynaplo/screens/charts_detail_tab.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;


void main() {
  test.group('Widget tests', () {
    testWidgets('HeroAnimatingSubjectsCard has a title',
        (WidgetTester tester) async {
      await tester.pumpWidget(HeroAnimatingSubjectsCard(
        title: 'Title',
        color: Colors.red,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
          print("Pressed");
        },
      ));

      // Create the Finders.
      final titleFinder = find.text('Title');

      expect(titleFinder, findsOneWidget);
    });

    testWidgets('HeroAnimatingMarksCard has a title and icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(HeroAnimatingMarksCard(
        title: 'Title',
        color: Colors.red,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
          print("Pressed");
        },
      ));

      // Create the Finders.
      final titleFinder = find.text('Title');
      final iconFinder = find.byIcon(Icons.create);
      expect(titleFinder, findsOneWidget);
      expect(iconFinder, findsOneWidget);
    });

    testWidgets('AnimatedNoticesCard has a title and a subtitle',
        (WidgetTester tester) async {
      await tester.pumpWidget(AnimatedTitleSubtitleCard(
        title: 'Title',
        subTitle: 'Subtitle',
        color: Colors.red,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
          print("Pressed");
        },
      ));

      // Create the Finders.
      final titleFinder = find.text('Title');
      final subFinder = find.text('Subtitle');
      expect(titleFinder, findsOneWidget);
      expect(subFinder, findsOneWidget);
    });

    testWidgets('AnimatedChartsCard has a title',
        (WidgetTester tester) async {
      await tester.pumpWidget(AnimatedChartsCard(
        title: 'Title',
        color: Colors.red,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: () {
          print("Pressed");
        },
      ));

      // Create the Finders.
      final titleFinder = find.text('Title');
      expect(titleFinder, findsOneWidget);
    });

    //TODO CHARTS WIDGET
  });
}

class ChartPoints {
  var count;
  var value;

  ChartPoints(this.count, this.value);
}