import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';

class NoticeDetailTab extends StatelessWidget {
  const NoticeDetailTab(
      {this.title,
        this.content,
        this.teacher,
        this.date,
        this.subject,
        this.color,
        this.id});

  final int id;
  final String title;
  final String content;
  final String teacher;
  final String date;
  final String subject;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: body(),
    );
  }

  Widget body(){
    return SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25),
                ),)
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                switch(index){
                  case 0:
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Szöveg:",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            capitalize(content),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ]);
                    break;
                  case 1:
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanár:",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            capitalize(teacher),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ]);
                    break;
                  case 2:
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dátum:",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            capitalize(date),
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ]);
                    break;
                }
              }
            )
          )
            //Expanded()
          ]
        )
    );
  }
}