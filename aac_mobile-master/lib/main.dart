import 'package:aac_mobile/tools/dataService/aqData.dart';
import 'package:aac_mobile/tools/preferences.dart';
import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:aac_mobile/tools/commService/customService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aac_mobile/tools/commService/service.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:aac_mobile/routes.dart';
import 'package:aac_mobile/tools/theme.dart';
import 'package:aac_mobile/login.dart';
import 'package:aac_mobile/signup.dart';
import 'package:aac_mobile/menu.dart';
import 'package:aac_mobile/addDevice.dart';
import 'package:aac_mobile/aquarium.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Future<User> getUserData() => UserPreferences().getUser();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthInterface>(create: (_) => AuthCustom()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider<DataInterface>(create: (_) => DataCustom()),
        ChangeNotifierProvider(create: (_) => AqProvider()),
      ],
      child: MaterialApp(
        //debugShowCheckedModeBanner: true,
        title: 'Flutter Demo',
        theme: ThemeData.from(colorScheme: highContrastLight),
        home: FutureBuilder(
            future: getUserData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                default:
                  if (snapshot.hasError)
                    return Text('Error: ${snapshot.error}');
                  else if (snapshot.data.token == null)
                    return LoginScreen();
                  else
                    UserPreferences().removeUser();
                  return Menu();
              }
            }),
        routes: {
          RtName.pgLogin: (context) => LoginScreen(),
          RtName.pgSignup: (context) => Signup(),
          RtName.pgMenu: (context) => Menu(),
          RtName.pgAddDevice: (context) => AddDevice(),
          RtName.pgAquarium: (context) => Aquarium(),
        },
      ),
    );
  }
}
