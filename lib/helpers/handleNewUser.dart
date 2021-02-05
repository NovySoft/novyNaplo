import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:novynaplo/main.dart' as main;
import 'package:novynaplo/ui/widgets/AdsDialog.dart';

void handleNewUser(BuildContext context) {
  main.isNew = false;
  showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (context) => AdsDialogNewUser(),
  );
}
