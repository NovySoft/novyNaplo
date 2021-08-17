import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/toasts/errorToast.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

import 'builders/bankAccDetailsBuilder.dart';
import 'builders/guardianDetailsBuilder.dart';
import 'builders/personalDetailsBuilder.dart';
import 'builders/schoolDetailsBuilder.dart';

class UserDetails extends StatefulWidget {
  const UserDetails({
    @required this.userDetails,
  });
  final Student userDetails;

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  bool _isAnimationDone = true;

  final GlobalKey<AnimatedListState> schoolDetailsListKey =
      GlobalKey<AnimatedListState>(debugLabel: "schoolDetailsListKey");
  bool schoolDetailsOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userDetails.name)),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                ErrorToast.showErrorToast(getTranslatedString("soon") + "...");
              },
              child: Container(
                width: (MediaQuery.of(context).size.width / 5)
                        .clamp(10, 100)
                        .toDouble() +
                    18,
                height: (MediaQuery.of(context).size.width / 5)
                        .clamp(10, 100)
                        .toDouble() +
                    18,
                decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Icon(
                  Feather.user,
                  size: (MediaQuery.of(context).size.width / 5)
                      .clamp(10, 100)
                      .toDouble(),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.userDetails.nickname ?? widget.userDetails.name,
                  style: TextStyle(fontSize: 21),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: Icon(Icons.edit),
                )
              ],
            ),
          ),
          SizedBox(height: 15),
          Divider(),
          ListView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              //* Personal details
              PersonalDetailsDropdown(
                userDetails: widget.userDetails,
              ),
              SizedBox(height: 10),
              Divider(),
              //* Guardian details
              GuardianDetailsDropdown(
                userDetails: widget.userDetails,
              ),
              SizedBox(height: 10),
              Divider(),
              //* Bank details
              BankAccountDropdown(
                bankAccDetails: widget.userDetails.bankAccount,
              ),
              SizedBox(height: 10),
              Divider(),
              //* School details
              SchoolDetailsDropdown(
                schoolDetails: widget.userDetails.institution,
              ),
              SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
