import 'package:flutter/material.dart';

import 'package:snc/model/login.dart';
import 'package:snc/model/user.dart';
import 'package:snc/common/global.dart';

class Profile{
  User user;
  Login login;
  int _theme;
  ThemeType get theme => ThemeType.values[this._theme];
  set theme(ThemeType themeType) => this._theme = themeType.index;
  Profile(){
    this.user = new User();
    this._theme = ThemeType.grey.index;
    this.login = null;
  }

  Profile.fromjson(Map<String, dynamic> json){
    this.user = User.fromjson(json['user']);
    this.login = Login.fromjson(json['login']);
    this._theme = json['theme'];
  }

  Map<String, dynamic> tojson(){
    return <String, dynamic>{
      'user':this.user.tojson(),
      'login':this.login.tojson(),
      'theme':this._theme,
    };
  }
}