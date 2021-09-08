import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/TitleSubtitleColumn.dart';

class PersonalDetailsDropdown extends StatefulWidget {
  PersonalDetailsDropdown({
    @required this.userDetails,
  });
  final Student userDetails;

  @override
  _PersonalDetailsDropdownState createState() =>
      _PersonalDetailsDropdownState();
}

class _PersonalDetailsDropdownState extends State<PersonalDetailsDropdown> {
  bool _isAnimationDone = true;

  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>(debugLabel: "personalDetailsListKey");
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
              for (int i = 6 - 1; i >= 0; i--) {
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
                      child: PersonalDetails(
                        index: i,
                        userInfo: widget.userDetails,
                      ),
                    ),
                  );
                });
                await delay(50);
              }
            } else {
              for (var i = 0; i < 6; i++) {
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
                  getTranslatedString("personalDetails") + ": ",
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
                  child: PersonalDetails(
                    index: index,
                    userInfo: widget.userDetails,
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class PersonalDetails extends StatelessWidget {
  const PersonalDetails({
    @required this.index,
    @required this.userInfo,
  });
  final int index;
  final Student userInfo;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("name+uid"),
              subtitle: userInfo.name + " #" + userInfo.uid,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 1:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("birthName"),
              subtitle: userInfo.birthName,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 2:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("mothersName"),
              subtitle: userInfo.mothersName,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 3:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("birthday"),
              subtitle: userInfo.birthDay.toHumanString(),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 4:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("placeOfBirth"),
              subtitle: userInfo.placeOfBirth,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      case 5:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("addresses"),
              subtitle: userInfo.addressList
                  .reduce((value, element) => value + "\n\n" + element),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      default:
        return SizedBox();
    }
  }
}
