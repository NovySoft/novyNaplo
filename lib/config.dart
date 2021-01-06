//These are not real values
//Please do not use these keys in production

String passKey = "NovyNovyNovyNovy"; //
String codeKey = "NovyNovyNovyNovy"; //
String userKey = "NovyNovyNovyNovy"; //
//Probably will change in future, agent used in network requests
//Please make sure these two variables are always the same
final String defaultUserAgent = "Novy.Kreta";
String userAgent = "Novy.Kreta";
//Client Id used to login
final String clientId = "kreta-ellenorzo-mobile";
final String userAgentFallback = "hu.ekreta.student/1.0.5/Android/0/0";

//menuLogo
String menuLogo = "assets/home.png";

//Admob appID
String adMob = "ca-app-pub-6768960612393878~9133319992";

//Admob
String bannerUnitId = "ca-app-pub-6768960612393878/1881515932";
//Test key: "ca-app-pub-3940256099942544/6300978111"
//Production key: "ca-app-pub-6768960612393878/1881515932"

//App version, so I can do special version names:
String currentAppVersionCode = "V1.0.6+21 APIv3 Alpha1";

//Is the app final release? (aka is/was in version.json)
//!If false don't do the new version check
//Mainly for travis ci builds and test builds
bool isAppRelease = true;

//Is the app playstore release?
//By default always release to playStore
bool isAppPlaystoreRelease = true;
