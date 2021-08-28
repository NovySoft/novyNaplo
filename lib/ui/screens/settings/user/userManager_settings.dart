import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/login_page.dart';
import 'user_detail_settings.dart';

class UserManager extends StatefulWidget {
  UserManager({
    @required this.setStateCallback,
  });
  final Function setStateCallback;

  @override
  _UserManagerState createState() => _UserManagerState();
}

class _UserManagerState extends State<UserManager> {
  List<Student> _items = [];

  @override
  void initState() {
    setStateCallback(
      createItemList: true,
      callExternalUpdate: false,
      callInternalUpdate: false,
    );
    super.initState();
  }

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
                            setStateCallback: setStateCallback,
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
              globals.allUsers = globals.allUsers
                  .map((e) {
                    int temp = _items.indexWhere(
                      (element) => element.userId == e.userId,
                    );
                    e.institution.userPosition = temp == -1 ? 0 : temp;
                    return e;
                  })
                  .toList()
                  .cast<Student>();
              //* I have a feeling this will cause problems
              DatabaseHelper.batchUpdateUserPositions(globals.allUsers);
              setStateCallback(
                callInternalUpdate: false,
                callExternalUpdate: true,
                createItemList: false,
              );
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
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => LoginPage(
                    setStateCallback: setStateCallback,
                    isNewUser: true,
                  ),
                ));
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

  void setStateCallback({
    bool callExternalUpdate = true,
    bool callInternalUpdate = true,
    bool createItemList = true,
  }) {
    if (callExternalUpdate) widget.setStateCallback(true);
    if (createItemList) {
      _items = List.from(globals.allUsers);
      _items.sort(
        (a, b) => a.institution.userPosition.compareTo(
          b.institution.userPosition,
        ),
      );
    }
    if (callInternalUpdate) {
      setState(() {
        _items = _items;
      });
    }
  }
}
