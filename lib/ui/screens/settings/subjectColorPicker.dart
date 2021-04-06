import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart' as subjectColors;

class SubjColor {
  String id;
  int color;
  String name;
  SubjColor({
    this.id,
    this.color,
    this.name,
  });

  @override
  String toString() => "$id:$color:$name";
}

class SubjectColorPicker extends StatefulWidget {
  @override
  _SubjectColorPickerState createState() => _SubjectColorPickerState();
}

class _SubjectColorPickerState extends State<SubjectColorPicker> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  List<SubjColor> colorList = [];
  Map<String, String> idToName = new Map<String, String>();

  void showColorPickerDialog(SubjColor input) {
    pickerColor = Color(input.color);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(capitalize(input.name)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              showLabel: true,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  subjectColors.subjectColorMap[input.id] = pickerColor.value;
                  reFreshColors();
                });
                //Also update database
                DatabaseHelper.insertColor(
                  input.id,
                  pickerColor.value,
                  input.name,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getIdToName();
    super.initState();
  }

  void getIdToName() async {
    idToName = await DatabaseHelper.getColorNames();
    reFreshColors();
  }

  void reFreshColors() {
    colorList = [];
    for (var n in subjectColors.subjectColorMap.entries) {
      colorList.add(SubjColor(
        id: n.key,
        color: n.value,
        name: idToName[n.key],
      ));
    }
    setState(() {
      colorList.sort(
        (a, b) => a.name.toLowerCase().compareTo(
              b.name.toLowerCase(),
            ),
      );
    });
  }

  // ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("subjectColors")),
      ),
      body: ListView.separated(
        separatorBuilder: (_, __) => Divider(),
        itemCount: colorList.length,
        itemBuilder: (context, index) {
          return ListTile(
            onTap: () {
              showColorPickerDialog(colorList[index]);
            },
            leading: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${colorList[index].name}:",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  "(${colorList[index].id.length > 25 ? colorList[index].id.substring(0, 25) + '...' : colorList[index].id})",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            trailing: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Color(colorList[index].color),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
