import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart' as subjectColors;

class SubjectColorPicker extends StatefulWidget {
  @override
  _SubjectColorPickerState createState() => _SubjectColorPickerState();
}

class _SubjectColorPickerState extends State<SubjectColorPicker> {
  // create some values
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  List<MapEntry<String, int>> colorList = [];

  void showColorPickerDialog(MapEntry<String, int> input) {
    pickerColor = Color(input.value);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(capitalize(input.key)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  subjectColors.subjectColorMap[input.key] = pickerColor.value;
                  reFreshColors();
                });
                //Also update database
                DatabaseHelper.insertColor(
                  input.key,
                  pickerColor.value,
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
    reFreshColors();
    super.initState();
  }

  void reFreshColors() {
    colorList = [];
    colorList.addAll(subjectColors.subjectColorMap.entries);
    colorList.sort((a, b) => a.key.compareTo(b.key));
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
            leading: Text(
              "${capitalize(colorList[index].key)}:",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            trailing: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Color(colorList[index].value),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}
