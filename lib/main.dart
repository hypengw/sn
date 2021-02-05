import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:snc/common/global.dart';
import 'package:snc/pages/login.dart';
import 'package:snc/pages/home.dart';
import 'package:snc/pages/record.dart';
import 'package:snc/pages/about.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();
  runApp(Sn());
}

class Sn extends StatelessWidget {

  @override
  Widget build(BuildContext context){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ThemeModel())
      ],
      child: new Consumer<ThemeModel>(
        builder: (BuildContext context,themeModel,Widget child) {
          return MaterialApp(
            initialRoute: "home_page",
            theme: Global.snTheme.genThemeDate(themeModel.theme),
            darkTheme: Global.snTheme.genThemeDate(ThemeType.dark),
            onGenerateRoute: (settings){
              return MaterialPageRoute(
                  builder: (context){
                      Widget result;
                      switch(settings.name){
                        case "record_page":result = RecordPage();
                        break;
                        case "login_page":result = LoginPage();
                        break;
                        case "home_page":result = HomePage();
                        break;
                        case "about_page":result = AboutPage();
                      }
                      if(settings.name != "home_page" && settings.name != "about_page")
                        result = WillPopScope(
                          onWillPop: ()async{
                            Navigator.pushReplacementNamed(context, "home_page");
                            return true;
                          },
                          child: result,
                        );
                      return result;
                    },
                  maintainState: true
                  );
            },
          );
        },
      ),
    );
  }
}
