import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/API/requestHandler.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as login;

var searchList = [];
bool isFetched = false;
TextEditingController _inputController = TextEditingController();

class SchoolSearchList extends StatefulWidget {
  @override
  _SchoolSearchListState createState() => new _SchoolSearchListState();
}

class _SchoolSearchListState extends State<SchoolSearchList> {
  @override
  void initState() {
    searchList = login.schoolList;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (login.schoolList.length == 0) {
        login.schoolList = await RequestHandler.getSchoolList();
        setState(() {
          isFetched = true;
          login.schoolList = login.schoolList;
          searchList = login.schoolList;
        });
      }
      setState(() {
        updateSearch(_inputController.text);
      });
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return new SimpleDialog(
      title: new Text(getTranslatedString("schSelector")),
      contentPadding: const EdgeInsets.all(10.0),
      children: <Widget>[
        new Container(
          child: new TextField(
              keyboardType: TextInputType.text,
              maxLines: 1,
              autofocus: true,
              controller: _inputController,
              onChanged: (String search) {
                setState(() {
                  updateSearch(search);
                });
              }),
          margin: new EdgeInsets.all(10.0),
        ),
        new Container(
          child: searchList != null && searchList.length > 0 && isFetched
              ? new ListView.builder(
                  itemBuilder: _itemBuilder,
                  itemCount: searchList.length,
                )
              : isFetched
                  ? Center(
                      child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          MdiIcons.emoticonSadOutline,
                          size: 50,
                        ),
                        Text(
                          "Nincs találat",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ))
                  : Center(
                      child: new CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.lightBlue),
                      ),
                    ),
          width: 320.0,
          height: 400.0,
        )
      ],
    );
  }

  void updateSearch(String searchText) {
    setState(() {
      searchList = List.from(login.schoolList);
    });

    if (searchText != "") {
      setState(() {
        searchList.removeWhere((dynamic element) {
          return !element.name
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase()) &&
              !element.code
                  .toString()
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
        });
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    return ListTile(
      title: new Text(searchList[index].name),
      subtitle: new Text(searchList[index].code),
      onTap: () {
        setState(() {
          login.selectedSchool = searchList[index];
          login.schoolController.text = login.selectedSchool.name;
          Navigator.pop(context);
        });
      },
    );
  }
}
