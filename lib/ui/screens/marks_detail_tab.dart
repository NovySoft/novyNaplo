import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/ui/parseSubjectToIcon.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class MarksDetailTab extends StatelessWidget {
  const MarksDetailTab({@required this.color, @required this.eval});

  final Evals eval;
  final Color color;

  Widget _buildBody() {
    Color markColor = Colors.purple;
    if (eval.tipus.nev == "Szazalekos") {
      if (eval.szamErtek >= 90) {
        markColor = Colors.green;
      } else if (eval.szamErtek >= 75) {
        markColor = Colors.lightGreen;
      } else if (eval.szamErtek >= 60) {
        markColor = Colors.yellow[800];
      } else if (eval.szamErtek >= 40) {
        markColor = Colors.orange;
      } else {
        markColor = Colors.red;
      }
    } else {
      switch (eval.szamErtek) {
        case 1:
          markColor = Colors.red;
          break;
        case 2:
          markColor = Colors.orange;
          break;
        case 3:
          markColor = Colors.yellow[800];
          break;
        case 4:
          markColor = Colors.lightGreen;
          break;
        case 5:
          markColor = Colors.green;
          break;
      }
    }
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            stretch: true,
            title: new Container(),
            leading: new Container(),
            backgroundColor: color,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              stretchModes: [StretchMode.zoomBackground],
              background: Icon(
                eval.icon == null
                    ? parseSubjectToIcon(subject: eval.tantargy.nev)
                    : eval.icon,
                size: 150,
                color: Colors.black38,
                textDirection: TextDirection.ltr,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                child: Text(
                  '${getTranslatedString("markInfo")}:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("subject")}: " + eval.tantargy.nev,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("theme")}: " + eval.tema.toString(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("markType")}: " + eval.tema.toString(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("markForm")}: " + eval.tipus.leiras,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("eval")}: " + eval.szovegesErtek,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: markColor,
                ),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("eval")} ${getTranslatedString("wNumber")}: " +
                    eval.szamErtek.toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: markColor,
                ),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${capitalize(getTranslatedString("weight"))}: " +
                    eval.sulySzazalekErteke.toString() +
                    "%",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("teacher")}: " + eval.tanar,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("dateGiveUp")}: " +
                    eval.rogzitesDatumaString,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10, width: 5),
              Text(
                "${getTranslatedString("dateCreated")}: " +
                    eval.keszitesDatumaString,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 500),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    FirebaseCrashlytics.instance.log("Shown Marks_detail_tab");
    return Scaffold(
      appBar: AppBar(
          title:
              Text(capitalize(eval.tantargy.nev + " " + eval.szovegesErtek))),
      body: _buildBody(),
    );
  }
}
