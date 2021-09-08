import 'package:flutter/material.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/ui/widgets/TitleSubtitleColumn.dart';

class BankAccountDropdown extends StatefulWidget {
  const BankAccountDropdown({
    @required this.bankAccDetails,
  });
  final BankAccount bankAccDetails;

  @override
  _BankAccountDropdownState createState() => _BankAccountDropdownState();
}

class _BankAccountDropdownState extends State<BankAccountDropdown> {
  bool _isAnimationDone = true;

  final GlobalKey<AnimatedListState> _animatedListKey =
      GlobalKey<AnimatedListState>(debugLabel: "bankAccountDetailsListKey");
  bool _listOpen = false;

  @override
  Widget build(BuildContext context) {
    if (widget.bankAccDetails == null) return SizedBox(width: 0, height: 0);
    return Column(
      children: [
        InkWell(
          onTap: () async {
            if (!_isAnimationDone) return;
            _isAnimationDone = false;
            if (_listOpen) {
              for (int i = 2 - 1; i >= 0; i--) {
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
                      child: BankAccountDetails(
                        index: i,
                        bankAccDetails: widget.bankAccDetails,
                      ),
                    ),
                  );
                });
                await delay(50);
              }
            } else {
              for (var i = 0; i < 2; i++) {
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
                  getTranslatedString("bankAccDetails") + ": ",
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
                  child: BankAccountDetails(
                    index: index,
                    bankAccDetails: widget.bankAccDetails,
                  ),
                ),
              );
            }),
      ],
    );
  }
}

class BankAccountDetails extends StatelessWidget {
  const BankAccountDetails({
    @required this.index,
    @required this.bankAccDetails,
  });
  final BankAccount bankAccDetails;
  final int index;

  @override
  Widget build(BuildContext context) {
    switch (index) {
      case 0:
        return Column(
          children: [
            TitleSubtitleColumn(
              title: getTranslatedString("accountNum"),
              subtitle: bankAccDetails.accountNumber,
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
              title: getTranslatedString("accountHolder"),
              subtitle: bankAccDetails.accountHolderName,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        );
        break;
      default:
        return SizedBox(height: 0, width: 0);
    }
  }
}
