import 'dart:math';

class User{
  String url;
  String mail;
  String pass;
  String machineID;

  User(){
    this.machineID = Random().nextInt(10).toString();
  }

  User.fromjson(Map<String,dynamic> json){
    this.url = json['url'];
    this.mail = json['mail'];
    this.pass = json['pass'];
    this.machineID = json['machineID'];
  }

  Map<String, dynamic> tojson(){
    return <String, dynamic>{
      'url':this.url,
      'mail':this.mail,
      'pass':this.pass,
      'machineID':this.machineID,
    };
  }
}