import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class UserManager extends StatefulWidget {
  @override
  _UserManagerState createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  final List<String> _items = [
    "Novy*",
    "Anna*",
    "Ebéd Elek",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTranslatedString("manageUsers"),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: [
          SizedBox(height: 15),
          Center(child: Text(getTranslatedString("reordUsers"))),
          SizedBox(height: 10),
          ReorderableListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              for (int index = 0; index < _items.length; index++)
                ListTile(
                  key: Key('$index'),
                  leading: Icon(MaterialIcons.drag_handle),
                  title: Text('${_items[index]}'),
                  trailing: GestureDetector(
                    onTap: () {
                      //TODO
                    },
                    child: Icon(Icons.edit),
                  ),
                  enableFeedback: true,
                ),
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final String item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
          ),
          SizedBox(height: 15),
          Center(
            child: ElevatedButton.icon(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              onPressed: () async {
                //TODO
              },
              icon: Icon(
                Feather.user_plus,
              ),
              label: Text(
                getTranslatedString("newUser"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
