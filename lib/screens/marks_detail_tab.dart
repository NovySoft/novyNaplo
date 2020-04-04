import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/widgets.dart';

class MarksDetailTab extends StatelessWidget {
  const MarksDetailTab(
      {this.numberValue,
      this.subject,
      this.id,
      this.name,
      this.color,
      this.theme,
      this.teacher,
      this.createDate,
      this.date,
      this.mode,
      this.weight,
      this.value,
      this.form,
      this.formName});

  final int id;
  final String name;
  final String theme;
  final String weight;
  final String date;
  final String teacher;
  final String mode;
  final String subject;
  final String value;
  final String formName;
  final String form;
  final String createDate;
  final int numberValue;
  final Color color;

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hero(
            tag: id,
            child: HeroAnimatingMarksCard(
              subTitle: "",
              title: name,
              color: color,
              heroAnimation: AlwaysStoppedAnimation(1),
              onPressed: null,
            ),
            // This app uses a flightShuttleBuilder to specify the exact widget
            // to build while the hero transition is mid-flight.
            //
            // It could either be specified here or in SongsTab.
            flightShuttleBuilder: (context, animation, flightDirection,
                fromHeroContext, toHeroContext) {
              return HeroAnimatingMarksCard(
                subTitle: "",
                title: name,
                color: color,
                heroAnimation: animation,
              );
            },
          ),
          Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                      child: Text(
                        'Jegy információk:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                    break;
                  case 1:
                    return SizedBox(
                      child: Text("Tantárgy: " + subject,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 2:
                    return SizedBox(
                      child: Text("Téma: " + theme.toString(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 3:
                    return SizedBox(
                      child: Text("Értékelés típusa: " + formName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 4:
                    if (form == "Mark" ||
                        form == "Diligence" ||
                        form == "Deportment") {
                      switch (numberValue) {
                        case 1:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                          break;
                        case 2:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          );
                          break;
                        case 3:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow[800])),
                          );
                          break;
                        case 4:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen)),
                          );
                          break;
                        case 5:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          );
                          break;
                        default:
                          return SizedBox(
                            child: Text("Értékelés: " + value,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          );
                          break;
                      }
                    } else if (form == "Percent") {
                      if (numberValue >= 90) {
                        return SizedBox(
                          child: Text("Értékelés: " + value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        );
                      } else if (numberValue >= 75) {
                        return SizedBox(
                          child: Text("Értékelés: " + value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen)),
                        );
                      } else if (numberValue >= 60) {
                        return SizedBox(
                          child: Text("Értékelés: " + value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800])),
                        );
                      } else if (numberValue >= 40) {
                        return SizedBox(
                          child: Text("Értékelés: " + value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        );
                      } else {
                        return SizedBox(
                          child: Text("Értékelés: " + value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      }
                    } else {
                      return SizedBox(
                        child: Text("Értékelés: " + value,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    }
                    break;
                  case 5:
                    if (form == "Mark" ||
                        form == "Diligence" ||
                        form == "Deportment") {
                      switch (numberValue) {
                        case 1:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                          break;
                        case 2:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          );
                          break;
                        case 3:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow[800])),
                          );
                          break;
                        case 4:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen)),
                          );
                          break;
                        case 5:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          );
                          break;
                        default:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " + numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          );
                          break;
                      }
                    } else if (form == "Percent") {
                      if (numberValue >= 90) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " + numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        );
                      } else if (numberValue >= 75) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " + numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen)),
                        );
                      } else if (numberValue >= 60) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " + numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800])),
                        );
                      } else if (numberValue >= 40) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " + numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        );
                      } else {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " + numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      }
                    } else {
                      return SizedBox(
                        child: Text(
                            "Értékelés számmal: " + numberValue.toString(),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    }
                    break;
                  case 6:
                    return SizedBox(
                      child: Text("Súly: " + weight,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 7:
                    return SizedBox(
                      child: Text("Tanár: " + teacher,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 8:
                    return SizedBox(
                      child: Text("Beírás dátuma: " + date,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 9:
                    return SizedBox(
                      child: Text("Létrehozás dátuma: " + createDate,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  default:
                    return SizedBox(height: 18);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because we're using different scaffolds.
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: _buildBody(),
    );
  }
}
