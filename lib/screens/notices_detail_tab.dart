import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/widgets.dart';

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
            //Expanded()
          ]
        )
    );
  }
}