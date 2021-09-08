import 'package:flutter/material.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class TitleSubtitleColumn extends StatelessWidget {
  const TitleSubtitleColumn({
    this.title,
    this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                (title ?? "") + ":",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
              Text(
                subtitle ?? getTranslatedString("unknown"),
                style: TextStyle(
                  fontSize: 16,
                ),
                overflow: TextOverflow.fade,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
