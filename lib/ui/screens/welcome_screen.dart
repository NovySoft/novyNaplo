import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:novynaplo/helpers/misc/delay.dart';
import 'package:novynaplo/i18n/translationProvider.dart';
import 'login_page.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();
  double animation = 0;

  @override
  void initState() {
    FirebaseCrashlytics.instance.log("Shown Welcome screen");
    FirebaseAnalytics().logEvent(name: "tutorial_begin");
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await delay(200);
      setState(() {
        animation = 1;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color(0xff121212),
      imagePadding: EdgeInsets.zero,
    );

    return Scaffold(
      body: SafeArea(
        child: IntroductionScreen(
          key: introKey,
          pages: [
            PageViewModel(
              titleWidget: AnimatedOpacity(
                opacity: animation,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 550),
                child: Text(
                  getTranslatedString("Welcome to novynaplo"),
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
                ),
              ),
              bodyWidget: AnimatedOpacity(
                opacity: animation,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 550),
                child: Text(
                  getTranslatedString("getStarted"),
                  style: TextStyle(
                    fontSize: 19.0,
                  ),
                ),
              ),
              image: AnimatedOpacity(
                opacity: animation,
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 550),
                child: Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 100.0,
                    child: Image.asset('assets/home.png'),
                  ),
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: getTranslatedString("thisAppOpenSource"),
              body: getTranslatedString("errAndGit"),
              image: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 100.0,
                  child: Image.asset('assets/git.png'),
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: getTranslatedString("thirdParty"),
              body: getTranslatedString("useThirdParties"),
              image: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 100.0,
                  child: Image.asset('assets/firebase.png'),
                ),
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              titleWidget: Column(children: [
                Text(
                  getTranslatedString("contributors"),
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5),
                Text(
                  getTranslatedString("appreciate"),
                  textAlign: TextAlign.center,
                ),
              ]),
              bodyWidget: Center(
                child: Column(
                  children: <Widget>[
                    PeopleCard(
                      name: "Novy",
                      job: getTranslatedString("leadDev"),
                    ),
                    PeopleCard(
                      name: "Zoller András",
                      job: getTranslatedString("markCalcDev"),
                    ),
                    PeopleCard(
                      name: "Gáti Gergely",
                      job: getTranslatedString("prManager"),
                    ),
                    PeopleCard(
                      name: "Dallos Levente",
                      job: getTranslatedString("jsDev"),
                    ),
                    PeopleCard(
                      name: "Gáspár Bernát",
                      job: getTranslatedString("designTip"),
                    ),
                    PeopleCard(
                      name: "Madács Márton",
                      job: getTranslatedString("mainDonator"),
                    ),
                    PeopleCard(
                      name: "Boapps/Filc",
                      job: "Ekréta API",
                    ),
                    PeopleCard(
                      name: "Stackoverflow",
                      job: getTranslatedString("stackPro"),
                    ),
                    PeopleCard(
                      name: "${getTranslatedString("manyOther")}...",
                      job: getTranslatedString("manyOtherJob"),
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "${getTranslatedString("you").toUpperCase()}",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          getTranslatedString("everyImp"),
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              decoration: pageDecoration,
            ),
          ],
          onDone: () {
            Navigator.pushReplacementNamed(context, LoginPage.tag);
            FirebaseAnalytics().logEvent(name: "tutorial_complete");
          },
          showSkipButton: true,
          skipFlex: 0,
          nextFlex: 0,
          skip: Text(getTranslatedString("skip")),
          next: const Icon(Icons.arrow_forward),
          done: Text(
            getTranslatedString("done"),
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.orange,
            activeColor: Colors.deepOrange,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ),
    );
  }
}

class PeopleCard extends StatelessWidget {
  const PeopleCard({this.name, this.job, this.image});
  final String name;
  final String job;
  final image;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          job,
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
