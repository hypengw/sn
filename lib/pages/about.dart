import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
class AboutPage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() => _AboutPage();
}

class _AboutPage extends State<AboutPage>{
  Future<PackageInfo> packageInfo;
  @override
  void initState() {
    super.initState();
    this.packageInfo = PackageInfo.fromPlatform();
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(title: new Text('关于',)),
      body: new FutureBuilder<PackageInfo>(
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.done)
              return new Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(left: 20,right: 20),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new Padding(padding: EdgeInsets.only(top: 70)),
                    new Image(image: AssetImage('graphics/ico.png'),width: 70,),
                    new Padding(padding: EdgeInsets.only(top: 20),
                        child: Text('当前版本 '+snapshot.data.version,
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12
                          ),
                        )
                    ),
                    new Padding(padding: EdgeInsets.only(top: 20),
                        child: Text('Sn监控是shinobi的非官方安卓客户端app',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15
                          ),
                        )
                    ),
                  ],
                ),
              );
            return Container();
          },
        future: this.packageInfo,
      ),
    );
  }
}