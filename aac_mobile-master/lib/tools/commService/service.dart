import 'package:http/io_client.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:aac_mobile/tools/commService/baseService.dart';



class AppUrl {
  static String liveBaseURL = "https://blynk-cloud.com";
  static const String localBaseURL = "https://10.0.2.2:5000/api/v1";

  static String baseURL = liveBaseURL;
  static String login = baseURL + "/login";
  static String register = baseURL + "/register";
  static String forgotPassword = baseURL + "/forgot-password";
  static String logout = baseURL + "/logout";
  static const String getVal = "/get";
  static const String setValQry = "value";
  static String devUrl;

  static void changeBaseUrl(String newUrl) {
    liveBaseURL = "https://$newUrl/api/v1";

    baseURL = liveBaseURL;
    login = baseURL + "/login";
    register = baseURL + "/register";
    forgotPassword = baseURL + "/forgot-password";
  }

  static void changeDevUrl(String token) {
    baseURL = liveBaseURL;
    devUrl = baseURL + "/" + token + getVal;
  }
}

class AuthRest with ChangeNotifier implements AuthInterface {

  AuthStatus _loggedInStatus = AuthStatus.NotLoggedIn;
  AuthStatus _registeredInStatus = AuthStatus.NotRegistered;

  final _ioc = new HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

  @override
  AuthStatus get loggedInStatus => _loggedInStatus;
  @override
  AuthStatus get registeredInStatus => _registeredInStatus;
  @override
  ResourceStatus get resStatus => ResourceStatus.Ready;

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    Map<String, dynamic> result;

    String basicAuth = 'Basic ' + base64Encode(utf8.encode('$email:$password'));

    _loggedInStatus = AuthStatus.Authenticating;
    notifyListeners();

    try {
      final http = new IOClient(_ioc);

      Response response = await http.post(
        AppUrl.login,
        headers: {'authorization': basicAuth},
      );

      print("status: ${response.statusCode}\nbody: ${response.body}\nheaders: ${response.headers}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);

        User authUser = User.fromJson(userData);

        AuthInterface.saveUser(authUser);

        _loggedInStatus = AuthStatus.LoggedIn;
        notifyListeners();

        result = {'status': true, 'message': 'Successful', 'user': authUser};
      } else {
        _loggedInStatus = AuthStatus.NotLoggedIn;
        notifyListeners();
        result = {
          'status': false,
          'message': json.decode(response.body)['error']
        };
      }
      return result;
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      _loggedInStatus = AuthStatus.NotLoggedIn;
      notifyListeners();
      result = {
        'status': false,
        'message': "Exception:\n${e.toString()}",
      };
      return result;
    }

  }

  @override
  Future<Map<String, dynamic>> signUp(String email, String password,
      {String name, String role}) async {

    final Map<String, dynamic> registrationData = {
      'email': email,
      'password': password,
      'name': name
    };


    _registeredInStatus = AuthStatus.Registering;
    notifyListeners();

    return await post(AppUrl.register,
        body: json.encode(registrationData),
        headers: {'Content-Type': 'application/json'})
        .then(onValue)
        .catchError(onError);
  }

  static Future<FutureOr> onValue(Response response) async {
    var result;
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {

      var userData = responseData['data'];

      User authUser = User.fromJson(userData);

      AuthInterface.saveUser(authUser);
      result = {
        'status': true,
        'message': 'Successfully registered',
        'data': authUser
      };
    } else {

      result = {
        'status': false,
        'message': 'Registration failed',
        'data': responseData
      };
    }

    return result;
  }

  static onError(error) {
    print("the error is $error.detail");
    return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  }

  Future<Map<String, dynamic>> signOut() {}
  Future<Map<String, dynamic>> remove() {}

  Future<Map<String, dynamic>> getResourceList() {}
  Future<Map<String, dynamic>> addResource(String name, String uuid, {int color}) {}
  Future<Map<String, dynamic>> deleteResource(String uuid) {}
}