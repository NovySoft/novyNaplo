import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
//import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

List<List<SubjectNicknames>> subjNicknames = [];

class SubjectNicknameSettings extends StatefulWidget {
  final bool isTimetable;

  SubjectNicknameSettings({
    @required this.isTimetable,
  });

  @override
  _SubjectNicknameSettingsState createState() =>
      _SubjectNicknameSettingsState();
}

class _SubjectNicknameSettingsState extends State<SubjectNicknameSettings> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      subjNicknames = await DatabaseHelper.getSubjNickMatrix(
        widget.isTimetable,
      );
      setState(() {
        subjNicknames = subjNicknames;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    subjNicknames = [];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(getTranslatedString("warning")),
              content: Text(
                getTranslatedString("effectOnNextStart"),
              ),
              actions: [
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isTimetable
              ? getTranslatedString("timetableNicknames")
              : getTranslatedString("subjectNicknames")),
        ),
        body: subjNicknames.length == 0
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.separated(
                separatorBuilder: (_, __) => Divider(),
                itemCount: subjNicknames.length,
                itemBuilder: (context, index) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: subjNicknames[index].length,
                    itemBuilder: (context, indexJ) {
                      TextEditingController _temp = new TextEditingController(
                        text: subjNicknames[index][indexJ].nickName,
                      );
                      return ListTile(
                        leading: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.6,
                          child: Text(
                            capitalize(subjNicknames[index][indexJ].fullName) +
                                ":" +
                                (widget.isTimetable
                                    ? "\n(${subjNicknames[index][indexJ].teacher})"
                                    : ""),
                            maxLines: widget.isTimetable ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.subtitle1.color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        trailing: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: 0.4,
                          child: TextFormField(
                            showCursor: false,
                            enableInteractiveSelection: false,
                            controller: _temp,
                            onTap: () async {
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                              await showChangeDialog(index, indexJ);
                              WidgetsBinding.instance.focusManager.primaryFocus
                                  ?.unfocus();
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => setState(() {
                                  _temp.text =
                                      subjNicknames[index][indexJ].nickName;
                                  subjNicknames = subjNicknames;
                                }),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> showChangeDialog(int index, int indexJ) async {
    GlobalKey<FormState> _formKey =
        GlobalKey<FormState>(debugLabel: "$index + $indexJ");
    TextEditingController _tempController = new TextEditingController(
      text: subjNicknames[index][indexJ].nickName,
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            capitalize(subjNicknames[index][indexJ].fullName) +
                ":" +
                (widget.isTimetable
                    ? "\n(${subjNicknames[index][indexJ].teacher})"
                    : ""),
            style: TextStyle(
              color: Theme.of(context).textTheme.subtitle1.color,
              fontSize: 16,
            ),
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (String input) async {
                if (_formKey.currentState != null) {
                  if (_formKey.currentState.validate()) {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    await DatabaseHelper.updateNickname(
                      Subject(
                        uid: subjNicknames[index][indexJ].uid,
                        name: _tempController.text,
                      ),
                    );
                    subjNicknames[index][indexJ].nickName =
                        _tempController.text;
                    subjectMap[subjNicknames[index][indexJ].uid].name =
                        _tempController.text;
                    Navigator.of(context).pop();
                  }
                }
              },
              validator: (input) {
                if (input == null || input.isEmpty) {
                  return getTranslatedString('mustntLeaveEmpty');
                }
                List<dynamic> interatorList =
                    List.from(subjNicknames).expand((i) => i).toList();
                interatorList.removeWhere(
                    (i) => i.category == subjNicknames[index][indexJ].category);
                if (interatorList
                        .indexWhere((element) => element.nickName == input) !=
                    -1) {
                  return getTranslatedString("noSameNick");
                }
                return null;
              },
              controller: _tempController,
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () async {
                if (_formKey.currentState != null) {
                  if (_formKey.currentState.validate()) {
                    WidgetsBinding.instance.focusManager.primaryFocus
                        ?.unfocus();
                    await DatabaseHelper.updateNickname(
                      Subject(
                        uid: subjNicknames[index][indexJ].uid,
                        name: _tempController.text,
                      ),
                    );
                    subjNicknames[index][indexJ].nickName =
                        _tempController.text;
                    subjectMap[subjNicknames[index][indexJ].uid].name =
                        _tempController.text;
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
