import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/data/models/subjectColor.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/helpers/ui/subjectColor.dart' as subjectColors;

class SubjectColorPicker extends StatefulWidget {
  @override
  _SubjectColorPickerState createState() => _SubjectColorPickerState();
}

class _SubjectColorPickerState extends State<SubjectColorPicker> {
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);
  List<List<SubjectColor>> colorMatrix = [];
  List<GlobalKey<AnimatedListState>> _listKeyList = [];
  List<bool> _listOpenList = [];
  TextEditingController hexInput = new TextEditingController();

  void showColorPickerDialog(
    SubjectColor input, {
    bool isCategoryEdit = false,
  }) {
    pickerColor = Color(input.color);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isCategoryEdit
                ? "${getTranslatedString('category')}: ${input.category}"
                : capitalize(input.id),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: changeColor,
              enableAlpha: false,
              pickerAreaHeightPercent: 0.8,
              hexInputBar: true,
              hexInputController: hexInput,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                if (isCategoryEdit) {
                  List<SubjectColor> tempList = colorMatrix.firstWhere(
                    (element) => element[0].category == input.category,
                  );
                  for (var n in tempList) {
                    setState(() {
                      subjectColors.subjectColorMap[n.id] = pickerColor.value;
                    });
                  }
                  DatabaseHelper.updateColorCategory(
                    input.category,
                    pickerColor.value,
                  );
                } else {
                  setState(() {
                    subjectColors.subjectColorMap[input.id] = pickerColor.value;
                  });
                  //Also update database
                  DatabaseHelper.insertColor(
                    input.id,
                    pickerColor.value,
                    input.category,
                  );
                }
                setState(() {
                  getColors();
                });
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
    FirebaseCrashlytics.instance.log("Shown SubjectColorPicker");
    _listOpenList = List.filled(subjectColors.subjectColorList.length, false);
    _listKeyList = [];
    for (var i = 0; i < subjectColors.subjectColorList.length; i++) {
      _listKeyList.add(
        GlobalKey<AnimatedListState>(debugLabel: "$i"),
      );
    }
    getColors();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getColors() async {
    subjectColors.subjectColorList = await DatabaseHelper.getColorNames();
    List<SubjectColor> tempColList = List.from(subjectColors.subjectColorList);
    colorMatrix = makeColorsMatrix(tempColList);
    setState(() {
      colorMatrix = colorMatrix;
    });
  }

  List<List<SubjectColor>> makeColorsMatrix(List<SubjectColor> input) {
    if (input.length == 0) return [];
    List<List<SubjectColor>> output = [[]];
    int index = 0;
    input.sort(
      (a, b) => a.category.toLowerCase().compareTo(
            b.category.toLowerCase(),
          ),
    );
    String categoryBefore = input[0].category;
    for (var n in input) {
      if (!(n.category == categoryBefore)) {
        output[index].sort(
          (a, b) => a.id.toLowerCase().compareTo(
                b.id.toLowerCase(),
              ),
        );
        index++;
        output.add([]);
        categoryBefore = n.category;
      }
      output[index].add(n);
    }
    return output;
  }

  void animationHandler(int index) {
    if (_listOpenList[index]) {
      for (int i = colorMatrix[index].length - 1; i >= 0; i--) {
        _listKeyList[index].currentState.removeItem(
          i,
          (context, animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: Offset(1.5, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.ease,
              )),
              child: ListTile(
                contentPadding: EdgeInsets.only(
                  left: 30,
                  right: 16,
                ),
                onTap: () {
                  showColorPickerDialog(colorMatrix[index][i]);
                },
                leading: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: Text(
                    "${colorMatrix[index][i].id}:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.subtitle1.color,
                    ),
                  ),
                ),
                trailing: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Color(colorMatrix[index][i].color),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }
    } else {
      for (var i = 0; i < colorMatrix[index].length; i++) {
        _listKeyList[index].currentState.insertItem(i);
      }
    }
    setState(() {
      _listOpenList[index] = !_listOpenList[index];
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
      body: colorMatrix.length == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    MdiIcons.emoticonSadOutline,
                    size: 50,
                  ),
                  SizedBox(height: 5),
                  Text(getTranslatedString("noColorYet")),
                ],
              ),
            )
          : ListView.separated(
              separatorBuilder: (_, __) => Divider(),
              itemCount: colorMatrix.length,
              itemBuilder: (context, index) {
                if (colorMatrix[index].length == 1) {
                  return ListTile(
                    onTap: () {
                      showColorPickerDialog(colorMatrix[index][0]);
                    },
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.75,
                          child: Text(
                            "${colorMatrix[index][0].id}:",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                            ),
                          ),
                        ),
                        Text(
                          "(${colorMatrix[index][0].category.length > 25 ? colorMatrix[index][0].category.substring(0, 25) + '...' : colorMatrix[index][0].category})",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).textTheme.subtitle1.color,
                          ),
                        ),
                      ],
                    ),
                    trailing: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Color(colorMatrix[index][0].color),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                } else {
                  Widget trailingWidget;
                  if (colorMatrix[index].map((e) => e.color).toSet().length >
                      1) {
                    trailingWidget = Wrap(
                      spacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ErrorToast.showErrorToast(
                              getTranslatedString("overwriteMultCols"),
                            );
                            showColorPickerDialog(
                              colorMatrix[index][0],
                              isCategoryEdit: true,
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: colorMatrix[index]
                                    .map((e) => Color(e.color))
                                    .toList(),
                              ),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            animationHandler(index);
                          },
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 150),
                            firstChild: const Icon(
                              Icons.keyboard_arrow_up,
                              size: 30,
                            ),
                            secondChild: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ),
                            crossFadeState: _listOpenList[index]
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                          ),
                        ),
                      ],
                    );
                  } else {
                    trailingWidget = Wrap(
                      spacing: 5,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ErrorToast.showErrorToast(
                              getTranslatedString("categoryEdit"),
                            );
                            showColorPickerDialog(
                              colorMatrix[index][0],
                              isCategoryEdit: true,
                            );
                          },
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Color(colorMatrix[index][0].color),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            animationHandler(index);
                          },
                          child: AnimatedCrossFade(
                            duration: const Duration(milliseconds: 150),
                            firstChild: const Icon(
                              Icons.keyboard_arrow_up,
                              size: 30,
                            ),
                            secondChild: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                            ),
                            crossFadeState: _listOpenList[index]
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        leading: FractionallySizedBox(
                          widthFactor: 0.75,
                          child: Text(
                            "${capitalize(colorMatrix[index][0].category)} (${colorMatrix[index].length}):",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                            ),
                          ),
                        ),
                        trailing: trailingWidget,
                      ),
                      AnimatedList(
                        physics: NeverScrollableScrollPhysics(),
                        key: _listKeyList[index],
                        shrinkWrap: true,
                        itemBuilder: (context, indexJ, animation) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(1.5, 0),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: animation,
                              curve: Curves.ease,
                            )),
                            child: ListTile(
                              contentPadding: EdgeInsets.only(
                                left: 30,
                                right: 16,
                              ),
                              onTap: () {
                                showColorPickerDialog(
                                    colorMatrix[index][indexJ]);
                              },
                              leading: FractionallySizedBox(
                                widthFactor: 0.75,
                                child: Text(
                                  "${colorMatrix[index][indexJ].id}:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .color,
                                  ),
                                ),
                              ),
                              trailing: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color:
                                      Color(colorMatrix[index][indexJ].color),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              },
            ),
    );
  }
}
