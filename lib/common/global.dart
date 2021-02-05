import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'package:snc/common/shinobiAPI.dart';
import 'package:snc/model/monitors.dart';
import 'package:snc/model/profile.dart';

class Global {
  static Profile profile;
  static ShinobiAPI sn;
  static SharedPreferences _sp;
  static SnTheme snTheme = SnTheme();
  static List<Monitor> monitors;

  static Future<void> init() async {
    Global._sp = await SharedPreferences.getInstance();
    //make sure sp loaded
    if(Global._sp.containsKey('profile')){
      Global.profile = Profile.fromjson(json.decode(Global._sp.getString('profile')));
    }else{
      Global.profile = new Profile();
    }
  //make sure profile loaded
    Global.sn = new ShinobiAPI();
    await Global.sn.init();
  }

  static void saveProfile(){
    Global._sp.setString('profile', json.encode(Global.profile.tojson()));
  }
}

class ProfileChangeNotifier extends ChangeNotifier {
  Profile get _profile => Global.profile;

  @override
  void notifyListeners() {
    Global.saveProfile();
    super.notifyListeners();
  }
}


enum ThemeType{
  dark,
  light,
  grey
}

PageTransitionsBuilder createSnTransitions(){
  return new NoAnimationPageTransitionsBuilder();
}

class NoAnimationPageTransitionsBuilder<T> extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return child;
  }
}

class SnTheme {
  Map<ThemeType, Map<String, Color>> _themeMap = new Map();
  SnTheme(){
    this._themeMap[ThemeType.grey] = <String, Color>{
      'primaryColor': Colors.grey,
      'primaryColorDark': Colors.black,
      'backgroundColor': Colors.white,
      'primaryColorLight': Colors.white54,
      'buttonColor': Colors.white70,
      'highlightColor': Colors.yellow,
      'hintColor': Colors.blueGrey,
    };
  }
  PageTransitionsTheme snTransitions(){
    return PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: createSnTransitions(),
        TargetPlatform.iOS: createSnTransitions(),
        });
  }
  ThemeData genThemeDate(ThemeType themeType){
    if(themeType == ThemeType.dark) return ThemeData.dark().copyWith(pageTransitionsTheme: snTransitions());
    Map<String, Color> colorMap = this._themeMap[themeType];
    return new ThemeData(
        primaryColor: colorMap['primaryColor'],
        backgroundColor: colorMap['backgroundColor'],
        primaryColorLight: colorMap['primaryColorLight'],
        buttonColor: colorMap['buttonColor'],
        highlightColor: colorMap['highlightColor'],
        primaryColorDark: colorMap['primaryColorDark'],
        hintColor: colorMap['hintColor'],
        pageTransitionsTheme: snTransitions(),
    );
  }

}

class ThemeModel extends ProfileChangeNotifier {
  ThemeType get theme => Global.profile.theme??ThemeType.grey;
  set theme(ThemeType themeType) {
    if(themeType == null || ! ThemeType.values.contains(themeType.index)){
      Global.profile.theme = ThemeType.grey;
    }
    notifyListeners();
  }
}

class SelectedNumModel extends ChangeNotifier{
  int _num = 0;
  int get num => this._num;
  void inc(){
    this._num++;
    this.notifyListeners();
  }
}

class VideoModel extends ChangeNotifier{

}