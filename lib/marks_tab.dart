import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novynotifier/login_page.dart';

import 'marks_detail_tab.dart';
import 'utils.dart';
import 'widgets.dart';
import 'dart:async';
import 'package:cipher2/cipher2.dart';
import 'config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
var returnArray = [];
SharedPreferences prefs;

void loadEvent() async{
  prefs = await SharedPreferences.getInstance();
  String passKey = config.passKey;
  String codeKey = config.codeKey;
  String userKey = config.userKey;
  String iv = config.iv;
  String decryptedCode = await Cipher2.decryptAesCbc128Padding7(prefs.getString("code"), codeKey, iv);
  String decryptedUser = await Cipher2.decryptAesCbc128Padding7(prefs.getString("user"), userKey, iv);
  String decryptedPass = await Cipher2.decryptAesCbc128Padding7(prefs.getString("password"), passKey, iv);
  var url = 'https://novy.vip/api/grades.php?code=$decryptedCode&user=$decryptedUser&pass=$decryptedPass';
  var response = await http.get(url);
  if(response.statusCode == 200){
    returnArray = response.body.split(";");
  }else{
    returnArray[0] = "Error:"+response.statusCode.toString();
    //print('Response status: ${response.statusCode}');
  }
  if(returnArray.length < 20){
    while(returnArray.length < 20){
      returnArray.add("");
    }
  }  
}

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static const title = 'Jegyek';
  static const androidIcon = Icon(Icons.music_note);
  static const iosIcon = Icon(CupertinoIcons.music_note);

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _MarksTabState createState() => _MarksTabState();
}

class _MarksTabState extends State<MarksTab>{
  int itemsLength = markCount;
  final _androidRefreshKey = GlobalKey<RefreshIndicatorState>();

  List<MaterialColor> colors;
  List<String> songNames;

  @override
  void initState(){
    loadEvent();
    //itemsLength = prefs.getInt("count");
    _setData();
    super.initState();
  }

  void _setData(){
    colors = getRandomColors(itemsLength);
    songNames = getRandomNames(itemsLength);
  }

  Future<void> _refreshData() {
    return Future.delayed(
      // This is just an arbitrary delay that simulates some network activity.
      const Duration(seconds: 2),
      () => setState(() => _setData()),
    );
  }

  Widget _listBuilder(BuildContext context, int index) {
                        if (index >= itemsLength) return null;

    // Show a slightly different color palette. Show poppy-ier colors on iOS
    // due to lighter contrasting bars and tone it down on Android.
    final color = defaultTargetPlatform == TargetPlatform.iOS
        ? colors[index]
        : colors[index].shade400;

    return SafeArea(
      top: false,
      bottom: false,
      child: Hero(
        tag: index,
        child: HeroAnimatingSongCard(
          song: songNames[index],
          color: color,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: () => Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (context) => SongDetailTab(
                id: index,
                song: songNames[index],
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Non-shared code below because:
  // - Android and iOS have different scaffolds
  // - There are differenc items in the app bar / nav bar
  // - Android has a hamburger drawer, iOS has bottom tabs
  // - The iOS nav bar is scrollable, Android is not
  // - Pull-to-refresh works differently, and Android has a button to trigger it too
  //
  // And these are all design time choices that doesn't have a single 'right'
  // answer.
  // ===========================================================================
  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MarksTab.title),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async => await _androidRefreshKey.currentState.show(),
          ),
        ],
      ),
      drawer: widget.androidDrawer,
      body: RefreshIndicator(
        key: _androidRefreshKey,
        onRefresh: _refreshData,
        child: ListView.builder(
          itemCount: markCount,
          padding: EdgeInsets.symmetric(vertical: 12),
          itemBuilder: _listBuilder,
        ),
      ),
    );
  }

  Widget _buildIos(BuildContext context) {
    return CustomScrollView(
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: _refreshData,
        ),
        SliverSafeArea(
          top: false,
          sliver: SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(_listBuilder),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(context) {
    return PlatformWidget(
      androidBuilder: _buildAndroid,
      iosBuilder: _buildIos,
    );
  }
}