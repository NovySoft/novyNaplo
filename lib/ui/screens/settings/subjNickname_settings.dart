import 'package:flutter/material.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/subjectNicknames.dart';
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
      subjNicknames = await DatabaseHelper.getSubjNickMatrix();
      setState(() {
        subjNicknames = subjNicknames;
      });
    });
    super.initState();
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
          : ListView.builder(
              itemCount: subjNicknames.length,
              itemBuilder: (context, index) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subjNicknames[index].length,
                  itemBuilder: (context, indexJ) {
                    return Text(subjNicknames[index][indexJ].nickName);
                  },
                );
              },
            ),
    );
  }
}
