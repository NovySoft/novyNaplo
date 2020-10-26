import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/global.dart' as globals;
//TODO: New onboarding with https://pub.dev/packages/introduction_screen

PageController controller = PageController();
var currentPageValue = 0.0;
AnimationController _animationController;
double size = 100;
double visibility = 0,
    visibilityTwo = 0,
    secondVisibility = 0,
    secondVisibilityTwo = 0,
    thirdVisibility = 0,
    thirdVisibilityTwo = 0;

class WelcomeScreen extends StatefulWidget {
  static String tag = 'welcome';
  static const title = 'Hello';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    Crashlytics.instance.log("Shown Welcome screen");
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    FirebaseAnalytics().logEvent(name: "tutorial_begin");
    WidgetsBinding.instance.addPostFrameCallback((_) => animate());
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      body: welcomeBody(),
    );
  }

  void animate() async {
    await sleep(2000);
    setState(() {
      size = 150;
    });
    await sleep(1000);
    setState(() {
      visibility = 1;
    });
    await sleep(1000);
    setState(() {
      visibilityTwo = 1;
    });
  }

  void animateSecond() async {
    await sleep(500);
    setState(() {
      size = 150;
    });
    await sleep(1000);
    setState(() {
      secondVisibility = 1;
    });
    await sleep(1000);
    setState(() {
      secondVisibilityTwo = 1;
    });
  }

  void animateThird() async {
    await sleep(500);
    setState(() {
      thirdVisibility = 1;
    });
    await sleep(1000);
    setState(() {
      thirdVisibilityTwo = 1;
    });
  }

  Widget welcomeBody() {
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
    return PageView.builder(
      controller: controller,
      itemBuilder: (context, position) {
        if (position == currentPageValue.floor()) {
          if (position == 0) {
            return Transform(
              transform: Matrix4.identity()
                ..rotateX(currentPageValue - position),
              child: firstWelcomeCard(),
            );
          } else if (position == 1) {
            animateSecond();
            return Transform(
              transform: Matrix4.identity()
                ..rotateX(currentPageValue - position),
              child: secondWelcomeCard(),
            );
          } else if (position == 2) {
            animateThird();
            return Transform(
              transform: Matrix4.identity()
                ..rotateX(currentPageValue - position),
              child: thirdWelcomeCard(),
            );
          } else if (position == 3) {
            return Transform(
              transform: Matrix4.identity()
                ..rotateX(currentPageValue - position),
              child: fourthWelcomeCard(),
            );
          }
          return Transform(
            transform: Matrix4.identity()..rotateX(currentPageValue - position),
            child: Container(
              color: position % 2 == 0 ? Colors.blue : Colors.pink,
              child: Center(
                child: Text(
                  "Page",
                  style: TextStyle(color: Colors.blue, fontSize: 22.0),
                ),
              ),
            ),
          );
        } else {
          if (position == 0) {
            return firstWelcomeCard();
          } else if (position == 1) {
            return secondWelcomeCard();
          } else if (position == 2) {
            return thirdWelcomeCard();
          } else if (position == 3) {
            return fourthWelcomeCard();
          } else {
            return Container();
          }
        }
      },
      itemCount: 4,
    );
  }

  Widget firstWelcomeCard() {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            width: size,
            height: size,
            child: logo,
          ),
          SizedBox(height: 5.0),
          AnimatedOpacity(
              opacity: visibility,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Text(
                  getTranslatedString("Welcome to novynaplo"),
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              )),
          SizedBox(
            height: 50,
          ),
          AnimatedOpacity(
              opacity: visibilityTwo,
              duration: Duration(milliseconds: 500),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(getTranslatedString("Swipe to countinue"),
                      style: TextStyle(fontSize: 24)),
                  Icon(Icons.arrow_forward)
                ],
              ))),
        ],
      ),
    );
  }

  Widget secondWelcomeCard() {
    final error = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.black,
          radius: 75.0,
          child: Image.asset('assets/error.png')),
    );

    final github = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.black,
          radius: 75.0,
          child: Image.asset('assets/git.png')),
    );

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[error, github],
          ),
          SizedBox(height: 5.0),
          AnimatedOpacity(
              opacity: secondVisibility,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Text(
                  getTranslatedString("thisAppOpenSource"),
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              )),
          SizedBox(
            height: 25,
          ),
          AnimatedOpacity(
              opacity: secondVisibilityTwo,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Text(getTranslatedString("errAndGit"),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24)),
              )),
          SizedBox(
            height: 25,
          ),
          AnimatedOpacity(
              opacity: secondVisibilityTwo,
              duration: Duration(milliseconds: 500),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(getTranslatedString("Swipe to countinue"),
                      style: TextStyle(fontSize: 24)),
                  Icon(Icons.arrow_forward)
                ],
              ))),
        ],
      ),
    );
  }

  Widget thirdWelcomeCard() {
    final firebase = Hero(
      tag: 'hero',
      child:
          CircleAvatar(radius: 65.0, child: Image.asset('assets/firebase.png')),
    );

    final admob = Hero(
      tag: 'hero',
      child: CircleAvatar(radius: 65.0, child: Image.asset('assets/admob.png')),
    );

    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left: 24.0, right: 24.0),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              firebase,
              SizedBox(
                width: 15,
              ),
              admob,
            ],
          ),
          SizedBox(height: 5.0),
          AnimatedOpacity(
              opacity: thirdVisibility,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Text(
                  getTranslatedString("thirdParty"),
                  style: TextStyle(fontSize: 32),
                  textAlign: TextAlign.center,
                ),
              )),
          SizedBox(
            height: 25,
          ),
          AnimatedOpacity(
              opacity: thirdVisibilityTwo,
              duration: Duration(milliseconds: 500),
              child: Center(
                child: Text(
                  getTranslatedString("useThirdParties"),
                  style: TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
              )),
          SizedBox(
            height: 25,
          ),
          AnimatedOpacity(
              opacity: thirdVisibilityTwo,
              duration: Duration(milliseconds: 500),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(getTranslatedString("Swipe to countinue"),
                      style: TextStyle(fontSize: 24)),
                  Icon(Icons.arrow_forward)
                ],
              ))),
        ],
      ),
    );
  }

  Widget fourthWelcomeCard() {
    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () async {
          Navigator.pushReplacementNamed(context, LoginPage.tag);
          FirebaseAnalytics().logEvent(name: "tutorial_complete");
        },
        padding: EdgeInsets.all(12),
        child: Text(getTranslatedString("login"),
            style: TextStyle(color: Colors.black)),
      ),
    );
    return Center(
        child: ListView(
      children: <Widget>[
        Text(
          getTranslatedString("contributors"),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32),
        ),
        SizedBox(
          height: 30,
        ),
        PeopleCard(name: "Novy", job: getTranslatedString("leadDev")),
        PeopleCard(
            name: "Zoller András", job: getTranslatedString("markCalcDev")),
        PeopleCard(name: "Gáti Gergely", job: getTranslatedString("adsMaker")),
        PeopleCard(name: "Dallos Levente", job: getTranslatedString("jsDev")),
        PeopleCard(
            name: "Gáspár Bernát", job: getTranslatedString("designTip")),
        PeopleCard(
            name: "Madács Márton", job: getTranslatedString("mainDonator")),
        PeopleCard(name: "Boapps", job: "Ekréta API"),
        PeopleCard(name: "Stackoverflow", job: getTranslatedString("stackPro")),
        PeopleCard(
            name: "${getTranslatedString("manyOther")}...",
            job: getTranslatedString("manyOtherJob")),
        Column(
          children: <Widget>[
            Text(
              "${getTranslatedString("you").toUpperCase()}",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
        SizedBox(
          height: 15,
        ),
        loginButton,
        SizedBox(
          height: 75,
        ),
      ],
    ));
  }
}

class PeopleCard extends StatelessWidget {
  const PeopleCard({this.name, this.job, this.image});
  final String name;
  final String job;
  final image;

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 3,
        ),
        Text(
          job,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
