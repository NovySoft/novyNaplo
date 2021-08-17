import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;

import 'user_detail_settings.dart';

class UserManager extends StatefulWidget {
  @override
  _UserManagerState createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  final List<Student> _items = List.from(globals.allUsers);

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
                  leading: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onLongPress: () {},
                    child: Icon(MaterialIcons.drag_handle),
                  ),
                  title: Text(
                    '${_items[index].nickname != null ? _items[index].nickname + "*" : _items[index].name}',
                  ),
                  trailing: InkWell(
                    borderRadius: BorderRadius.circular(32),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => UserDetails(
                            userDetails: _items[index],
                          ),
                        ),
                      );
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
                final Student item = _items.removeAt(oldIndex);
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
