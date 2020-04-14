import 'package:flutter/material.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => animate());
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: welcomeBody(),
    );
  }

  void animate() async {
    await sleep1();
    await sleep1();
    setState(() {
      size = 150;
    });
    await sleep1();
    setState(() {
      visibility = 1;
    });
    await sleep1();
    setState(() {
      visibilityTwo = 1;
    });
  }

  void animateSecond() async {
    await sleep2();
    setState(() {
      size = 150;
    });
    await sleep1();
    setState(() {
      secondVisibility = 1;
    });
    await sleep1();
    setState(() {
      secondVisibilityTwo = 1;
    });
  }

  void animateThird() async {
    await sleep2();
    setState(() {
      thirdVisibility = 1;
    });
    await sleep1();
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
                  "Üdv a Novy Naplóban!",
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
                  Text("Húzd el a kezdéshez", style: TextStyle(fontSize: 24)),
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
                  "Ez az alkalmazás még csak BÉTA változat!",
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
                child: Text(
                    "Az alkalmazás több hibát is tartalmazhat, ezeket a novynaplo@gmail.com címen tudod bejelenteni, vagy a projekt hivatalos GitHub oldalán (NovySoft/NovyNaplo), ahol megoldásaid/ötleteidet is meg tudod osztani a hibával kapcsolatosan!",
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
                  Text("Húzd tovább ", style: TextStyle(fontSize: 24)),
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
                  "Harmadik felek és adatgyűjtés",
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
                  "Az alkalmazás bizonyos külső szolgáltatásokat is használ (admob,firebase), amik megoszthatják adataidat harmadik félel is (google, facebook, stb.). Ezek a megosztott adatok nem személyesek, hanem általános hibakeresésre szolgálóak. \nBármilyen adat kiszárvárgásért a NovySoft nem tehető felelősé",
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
                  Text("Húzd tovább ", style: TextStyle(fontSize: 24)),
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
          var prefs = await SharedPreferences.getInstance();
          prefs.setBool("isNew", false);
          Navigator.pushReplacementNamed(context, LoginPage.tag);
        },
        padding: EdgeInsets.all(12),
        child: Text('Bejelentkezés', style: TextStyle(color: Colors.black)),
      ),
    );
    return Center(
        child: ListView(
      children: <Widget>[
        Text(
          "Akik az apphoz hozzájárultak:",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32),
        ),
        SizedBox(
          height: 30,
        ),
        PeopleCard(name: "Novy", job: "Fő fejlesztő"),
        PeopleCard(name: "Zoller András", job: "Jegyszámoló programja"),
        PeopleCard(name: "Gáti Gergely", job: "Reklámok készítője"),
        PeopleCard(name: "Dallos Levente", job: "JS programozó"),
        PeopleCard(name: "Gáspár Bernát", job: "Design tanácsadó"),
        PeopleCard(name: "Madács Márton", job: "Fő finanszírozó"),
        PeopleCard(name: "Boapps", job: "Ekréta API"),
        PeopleCard(
            name: "Stackoverflow", job: "Informatika problémák megoldása :)"),
        PeopleCard(
            name: "Sokan Mások...", job: "Finanszírozás\nTesztelés\nÖtletek"),
        Column(
          children: <Widget>[
            Text(
              "TE",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 3,
            ),
            Text(
              "Nekünk minden felhasználó értékes!",
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
