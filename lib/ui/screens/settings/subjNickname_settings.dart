import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/description.dart';
import 'package:novynaplo/data/models/subject.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';
import 'package:novynaplo/helpers/misc/capitalize.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

List<List<SubjectNicknames>> subjNicknames = [];

class SubjectNicknameSettings extends StatefulWidget {
  @override
  _SubjectNicknameSettingsState createState() =>
      _SubjectNicknameSettingsState();
}

class _SubjectNicknameSettingsState extends State<SubjectNicknameSettings> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //subjNicknames = await DatabaseHelper.getSubjNickMatrix();
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
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("subjectNicknames")),
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
                        widthFactor: 0.6,
                        child: Text(
                          capitalize(subjNicknames[index][indexJ].fullName) +
                              ":",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.subtitle1.color,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      trailing: FractionallySizedBox(
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
                            //subjNicknames = await DatabaseHelper.getSubjNickMatrix();
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() {
                                _temp.text =
                                    subjNicknames[index][indexJ].nickName;
                                subjNicknames = subjNicknames;
                                //Fixme: refactor in such way that no application is required
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
    );
  }

  Future<void> showChangeDialog(int index, int indexJ) async {
    TextEditingController _tempController = new TextEditingController(
      text: subjNicknames[index][indexJ].nickName,
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            capitalize(subjNicknames[index][indexJ].fullName) + ":",
            style: TextStyle(
              color: Theme.of(context).textTheme.subtitle1.color,
              fontSize: 16,
            ),
          ),
          content: TextFormField(
            controller: _tempController,
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text('Ok'),
              onPressed: () async {
                /*await DatabaseHelper.insertSubjNick(
                  Subject(
                    name: _tempController.text,
                    fullName: subjNicknames[index][indexJ].fullName,
                    category: Description(
                      name: subjNicknames[index][indexJ].category,
                    ),
                  ),
                );*/
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
