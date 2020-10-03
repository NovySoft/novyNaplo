import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorMessageBuilder {
  static ErrorWidgetBuilder build() {
    ErrorWidgetBuilder func = (FlutterErrorDetails errorDetails) {
      ErrorMessage errorMessage = ErrorMessage(errorDetails);
      return BlueScreenErrorMessageTheme.build(errorMessage);
    };
    return func;
  }
}

class RowErrorStacktrace {
  String number;
  String message;
  String package;
  String line;

  RowErrorStacktrace(
      {this.number = "", this.message = "", this.package = "", this.line = ""});
}

class ErrorMessage {
  String exception;
  String title;
  String message;
  String info;
  List<RowErrorStacktrace> stacktrace;

  ErrorMessage(FlutterErrorDetails errorDetails) {
    List<String> listStacktrace = errorDetails.stack.toString().split("\n");
    if (errorDetails
            .toString(minLevel: DiagnosticLevel.debug)
            .split("\n")
            .length >=
        6) {
      title =
          errorDetails.toString(minLevel: DiagnosticLevel.debug).split("\n")[2];
      message =
          errorDetails.toString(minLevel: DiagnosticLevel.info).split("\n")[3];
      info =
          errorDetails.toString(minLevel: DiagnosticLevel.info).split("\n")[5];
    } else {
      title = errorDetails.toString(minLevel: DiagnosticLevel.debug);
      message = "";
      info = "";
    }
    exception = errorDetails.toStringShort();
    stacktrace = List();

    for (String stacktrace in listStacktrace) {
      List<String> msg = stacktrace.split("     ");
      if (msg.length > 1) {
        RowErrorStacktrace stack = RowErrorStacktrace();
        stack.package = stacktrace.split(" ").last;

        stack.number = msg[0];
        stack.message = msg[1];
        List<String> msgLine = stacktrace.split(":");
        stack.line = msgLine[msgLine.length - 2];

        this.stacktrace.add(stack);
      }
    }
  }
}

class BlueScreenErrorMessageTheme {
  static Widget build(ErrorMessage errorMessage) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 24),
                  color: Color(0xff2067b2),
                  child: Column(textDirection: TextDirection.ltr, children: <
                      Widget>[
                    Container(
                        constraints: BoxConstraints(minWidth: double.infinity),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.ltr,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 32.0, horizontal: 32),
                                child: Text(
                                  "):",
                                  textDirection: TextDirection.ltr,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 100,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(12),
                                  constraints:
                                      BoxConstraints(minWidth: double.infinity),
                                  child: Text(
                                    errorMessage.exception,
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  )),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                child: Text(
                                  errorMessage.title,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 36),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  errorMessage.message,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 16),
                                child: Text(
                                  errorMessage.info,
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              )
                            ])),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: buildRowStacktraceWidget(errorMessage),
                        textDirection: TextDirection.ltr,
                      ),
                    )
                  ]))
            ]));
  }

  static List<Widget> buildRowStacktraceWidget(ErrorMessage errorMessage) {
    List<Widget> listWidget = List();
    for (RowErrorStacktrace row in errorMessage.stacktrace) {
      listWidget.add(Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: Color(0xff4ba5e1)),
        margin: EdgeInsets.symmetric(vertical: 4),
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Text(row.number, style: TextStyle(color: Colors.blue))),
            Expanded(
                child: Text(row.message,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)))
          ]),
          Text(row.message,
              textDirection: TextDirection.ltr,
              style: TextStyle(
                  fontSize: 16, color: Colors.white.withOpacity(0.8))),
          Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text(row.package,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(fontSize: 16, color: Colors.white))),
          Row(
            children: <Widget>[
              Spacer(),
              Container(
                padding: EdgeInsets.all(6),
                margin: EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Text("line " + row.line,
                    textDirection: TextDirection.ltr,
                    style: TextStyle(fontSize: 16, color: Color(0xff2067b2))),
              )
            ],
          )
        ]),
      ));
    }
    return listWidget;
  }
}
