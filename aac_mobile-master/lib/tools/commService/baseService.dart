import 'package:aac_mobile/tools/preferences.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/dataService/primData.dart';

enum AuthStatus {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  Registering,
  LoggedOut
}

enum ResourceStatus {
  Ready,
  Connecting,
  OpeningUsrInfo,
  GettingRes,
  AddingRes,
  ClosingRes,
  RemovingRes,
  Error
}

abstract class AuthInterface with ChangeNotifier {
  AuthStatus get loggedInStatus;
  AuthStatus get registeredInStatus;
  ResourceStatus get resStatus;

  Future<Map<String, dynamic>> signIn(String email, String password);
  Future<Map<String, dynamic>> signUp(String email, String password, {String name, String role});
  Future<Map<String, dynamic>> signOut();
  Future<Map<String, dynamic>> remove();

  static void saveUser(User authUser) {UserPreferences().saveUser(authUser);}
  static Future<User> getUser() async {return await UserPreferences().getUser();}
  static void removeUser() {UserPreferences().removeUser();}

  Future<Map<String, dynamic>> getResourceList();
  Future<Map<String, dynamic>> addResource(String name, String uuid, {int color});
  Future<Map<String, dynamic>> deleteResource(String uuid);
}

abstract class DataInterface with ChangeNotifier {
  void init(Map<String, PrimData> dataNeeded, String token, {bool updatesOn = false, int updatePer = 1});

  set updates(bool on);
  Map<String, dynamic> get values;
  set values(Map<String, dynamic> val);
}
