import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/i18n/translationProvider.dart';

class GuardianDetailsDropdown extends StatefulWidget {
  GuardianDetailsDropdown({
    @required this.userDetails,
  });
  final Student userDetails;

  @override
  _GuardianDetailsDropdownState createState() =>
      _GuardianDetailsDropdownState();
}

class _GuardianDetailsDropdownState extends State<GuardianDetailsDropdown> {
  bool _isAnimationDone = true;
  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>(debugLabel: "guardianDetailsAnimatedList");
  bool _listOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (!_isAnimationDone) return;
            _isAnimationDone = false;
            if (_listOpen) {
              for (int i = widget.userDetails.parents.length - 1; i >= 0; i--) {
                _animatedListKey.currentState.removeItem(i,
                    (context, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.ease,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: GuardianDetails(
                        guardianInfo: widget.userDetails.parents[i],
                      ),
                    ),
                  );
                });
                await delay(50);
              }
            } else {
              for (var i = 0; i < widget.userDetails.parents.length; i++) {
                _animatedListKey.currentState.insertItem(i);
                await delay(50);
              }
            }
            setState(() {
              _isAnimationDone = true;
              _listOpen = !_listOpen;
            });
          },
          child: Container(
            height: 45,
            child: Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  getTranslatedString("guardianDetails") + ": ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 150),
                  firstChild: const Icon(
                    Icons.keyboard_arrow_up,
                    size: 30,
                  ),
                  secondChild: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                  crossFadeState: _listOpen
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        AnimatedList(
            key: _animatedListKey,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.ease,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: GuardianDetails(
                    guardianInfo: widget.userDetails.parents[index],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class GuardianDetails extends StatelessWidget {
  const GuardianDetails({
    @required this.guardianInfo,
  });
  final Parent guardianInfo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Text(
                guardianInfo.name + " #" + guardianInfo.uid,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            //* Telefon
                            Icon(Feather.phone, size: 16),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                guardianInfo.phoneNumber ??
                                    getTranslatedString("unknown"),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            //* Telefon
                            Icon(Feather.mail, size: 16),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                guardianInfo.email ??
                                    getTranslatedString("unknown"),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        if (guardianInfo.isLegalGuardian != null)
                          if (guardianInfo.isLegalGuardian)
                            Row(
                              children: [
                                //* Telefon
                                Icon(
                                  MaterialCommunityIcons.account_child,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    getTranslatedString("legGuardian"),
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
