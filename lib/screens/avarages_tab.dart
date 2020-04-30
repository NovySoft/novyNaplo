import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;

List<Avarage> avarageList = [];

class AvaragesTab extends StatelessWidget {
  static String tag = 'avarages';
  static const title = 'Átlagok';

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(AvaragesTab.title),
      ),
      drawer: getDrawer(AvaragesTab.tag, context),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return avaragesList(context);
  }
}

//TODO refactor to parse avarages before the rendering process
Widget avaragesList(BuildContext context) {
  return ListView.separated(
    separatorBuilder: (context, index) => Divider(),
    itemCount: avarageList.length + globals.adModifier,
    itemBuilder: (context, index) {
      //*Make the colors here
      Color avgColor = Colors.red;
      if (index >= avarageList.length) {
        return ListTile(
          title: SizedBox(
            height: 100,
          ),
        );
      } else {
        return ListTile(
          title: Text(avarageList[index].subject,
              style: TextStyle(color: avgColor)),
          trailing:
              Text(avarageList[index].ownValue, style: TextStyle(color: avgColor)),
        );
      }
    },
  );
}
