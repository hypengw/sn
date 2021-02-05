import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:snc/common/global.dart';
import 'package:snc/pages/widget.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _conServerUrl = TextEditingController();
  TextEditingController _conMail = TextEditingController();
  TextEditingController _conPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conServerUrl.text = Global.sn.user.url??'';
    _conMail.text = Global.sn.user.mail??'';
    _conPass.text = Global.sn.user.pass??'';
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("我的设备")
      ),
      drawer: new SnDrawer(selectPage: "login_page"),
      body: new Stack(
          children: <Widget>[
            new Form(
              child: new Column(
                children: <Widget>[
                  new TextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: _conServerUrl,
                    decoration: InputDecoration(
                      labelText: "设备地址",
                      icon: Icon(Icons.cloud),
                    ),
                  ),
                  new TextField(
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    controller: _conMail,
                    decoration: InputDecoration(
                      labelText: "用户邮箱",
                      icon: Icon(Icons.person),
                    ),
                  ),
                  new TextField(
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    controller: _conPass,
                    decoration: InputDecoration(
                      labelText: "密码",
                      icon: Icon(Icons.lock)
                    ),
                  ),
                  new Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: new Row(
                      children: <Widget>[
                        new Expanded(
                          child: new RaisedButton(
                            padding: const EdgeInsets.all(15.0),
                            child: Text('连接'),
                            onPressed: () async {
                              Global.sn.user.mail = _conMail.text;
                              Global.sn.user.pass = _conPass.text;
                              Global.sn.user.url = _conServerUrl.text;
                              if(await Global.sn.loginSn()) {
                                Fluttertoast.showToast(
                                    msg: "登录成功"
                                );
                                Global.saveProfile();
                                Navigator.pushReplacementNamed(context, 'home_page');
                              }else {
                                Fluttertoast.showToast(
                                    msg: "登录失败"
                                );
                              }
                            },

                          )
                        ),
                      ]
                    )
                  )
                ],
              ),
            ),
          ]
      )
    );
  }
}

