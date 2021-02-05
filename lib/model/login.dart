
class Login {
  bool ok;
  _User user;

  Login.fromjson(Map<String, dynamic> json){
    this.ok = json['ok'];
    this.user = json['ok']?_User.fromjson(json['\$user']):null;
  }
  
  Map<String,dynamic> tojson(){
    return <String, dynamic>{
      'ok':this.ok,
      '\$user':this.user?.tojson(),
    };
  }
  
}

class _User {
  String auth_token;
  String ke;

  _User.fromjson(Map<String, dynamic> json) {
    this.auth_token = json['auth_token'];
    this.ke = json['ke'];
  }
  Map<String, String> tojson(){
    return <String, String>{
      'auth_token':this.auth_token,
      'ke':this.ke,
    };
  }
}