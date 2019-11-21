import 'package:flutter/material.dart';
import 'package:novynaplo/config.dart';
import 'package:novynaplo/marks_tab.dart';
import 'package:flutter/services.dart';

var lista = ["assddasd", "alma", "szilva", "Novy"];

class AvaragesTab extends StatelessWidget {
  static String tag = 'avarages';
  static const title = 'Átlagok';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(AvaragesTab.title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child:
                    Center(child: new Image.asset(menuLogo, fit: BoxFit.fill))),
            ListTile(
              title: Text('Jegyek'),
              leading: Icon(Icons.create),
              onTap: () {
                try {
                  Navigator.pushNamed(context, MarksTab.tag);
                } on PlatformException catch (e) {
                  print(e.message);
                }
              },
            ),
            ListTile(
              title: Text('Átlagok'),
              leading: Icon(Icons.all_inclusive),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return avaragesList(context);
  }
}

Widget avaragesList(BuildContext context) {
  return ListView.separated(
    separatorBuilder: (context, index) => Divider(),
    itemCount: lista.length,
    itemBuilder: (context, index) {
      return ListTile(
        title: Text(lista[index]),
      );
    },
  );
}
