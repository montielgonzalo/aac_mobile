import 'package:http/io_client.dart';
import 'dart:io';
import 'package:http/http.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:mysql1/mysql1.dart';
import 'package:flutter/material.dart';
import 'package:aac_mobile/tools/dataService/primData.dart';
import 'package:aac_mobile/tools/dataService/userData.dart';
import 'package:aac_mobile/tools/commService/baseService.dart';
import 'package:aac_mobile/tools/dataService/aqData.dart';
//import 'package:pausable_timer/pausable_timer.dart';


class CustomAppUrl {
  static const String blynkURL = "https://blynk-cloud.com";
  static const String sqlURL = "gator4231.hostgator.com";
  static const int port = 3306;

  static const String user = "automare_aacmobi";
  static const String password = "AAC#2021#mobile";
  static const String database = "automare_aac2021";

  static const String getPin = "/get";
  static const String setPin = "/update";
  static const String setPinQry = "value";
  static String devUrl;

  static String getUrl(String token, String pin, {String value}) {
    String pinOp = value != null ? setPin : getPin;
    String query = value != null ? "?" + setPinQry + "=" + value: "";
    return blynkURL + "/" + token + pinOp + "/" + pin + query;
  }

}

class AuthCustom with ChangeNotifier implements AuthInterface {
  final _settings = new ConnectionSettings(
      host: CustomAppUrl.sqlURL,
      port: CustomAppUrl.port,
      user: CustomAppUrl.user,
      password: CustomAppUrl.password,
      db: CustomAppUrl.database
  );

  AuthStatus _loggedInStatus = AuthStatus.NotLoggedIn;
  AuthStatus _registeredInStatus = AuthStatus.NotRegistered;
  ResourceStatus _resStatus = ResourceStatus.Ready;

  @override
  AuthStatus get loggedInStatus => _loggedInStatus;
  @override
  AuthStatus get registeredInStatus => _registeredInStatus;
  @override
  ResourceStatus get resStatus => _resStatus;

  Map<String, dynamic> _loggedResp(bool ok, String msg, {User user}) {
    _loggedInStatus = ok ? AuthStatus.LoggedIn : AuthStatus.NotLoggedIn;
    notifyListeners();
    return {'status': ok, 'message': msg, 'user': user,};
  }

  // INTERFAZ PARA USUARIOS

  @override
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    MySqlConnection conn;
    _loggedInStatus = AuthStatus.Authenticating;
    notifyListeners();

    try {
      conn = await MySqlConnection.connect(_settings);
      Results res = await conn.query('select password, idUsuario, name, type from Usuario where email = ?', [email]);

      if (res.isEmpty)
        return _loggedResp(false, "El usuario no existe");
      var row = res.elementAt(0);
      if (row[0].toString() != password)
        return _loggedResp(false, "Contraseña inválida");

      User authUser = User(
        email: email,
        password: password,
        id: int.tryParse(row[1].toString()),
        name: row[2].toString(),
        role: row[3].toString(),
      );
      AuthInterface.saveUser(authUser);
      return _loggedResp(true, 'Autenticado!', user: authUser);

    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _loggedResp(false, "Exception:\n${e.toString()}");
    } finally {
      if (conn != null)
        conn.close();
    }
  }

  Map<String, dynamic> _regResp(bool ok, String msg, {var data}) {
    _registeredInStatus = ok ? AuthStatus.Registered : AuthStatus.NotRegistered;
    notifyListeners();
    return {'status': ok, 'message': msg, 'data': data,};
  }
  
  @override
  Future<Map<String, dynamic>> signUp(String email, String password,
      {String name, String role}) async {
    MySqlConnection conn;
    _registeredInStatus = AuthStatus.Registering;
    notifyListeners();

    try {
      conn = await MySqlConnection.connect(_settings);
      Results res = await conn.query('select email from Usuario where email = ?', [email]);
      if (res.isNotEmpty)
        return _regResp(false, 'Falló el registro', data: "El usuario ya existe");

      Results result = await conn.query('insert into Usuario (email, password, name, validationCode, state, type) values (?, ?, ?, ?, ?, ?)',
          [email, password, name, 1, 1, role]);
      User authUser = User(
        email: email,
        password: password,
        id: result.insertId,
        name: name,
        role: role,
      );

      AuthInterface.saveUser(authUser);
      return _regResp(true, "Registrado exitosamente", data: authUser);
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _regResp(false, "Exception:\n${e.toString()}");
    } finally {
      if (conn != null)
        conn.close();
    }
  }

  Future<Map<String, dynamic>> signOut() async {
    try {
      _registeredInStatus = AuthStatus.LoggedOut;
      notifyListeners();
      AuthInterface.removeUser();
      return {'status': true, 'message': 'User signed out!!!'};
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _regResp(false, "Exception:\n${e.toString()}");
    }
  }

  Future<Map<String, dynamic>> remove() async {
    assert (_loggedInStatus == AuthStatus.LoggedIn);
    MySqlConnection conn;
    try {
      User user = await AuthInterface.getUser();
      conn = await MySqlConnection.connect(_settings);
      await conn.query('delete from Usuario where email = ?', [user.email]);
      _registeredInStatus = AuthStatus.LoggedOut;
      notifyListeners();
      return {'status': true, 'message': 'Usuario removido!!!'};
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return {'status': false, 'message': "Exception:\n${e.toString()}"};
    } finally {
      if (conn != null)
        conn.close();
    }
  }

  // INTERFAZ PARA ACUARIOS

  Future<Map<String, dynamic>> _getAcUserId(ResourceStatus rs) async {
    assert (_loggedInStatus == AuthStatus.LoggedIn);
    _resStatus = ResourceStatus.Connecting;
    notifyListeners();
    MySqlConnection conn = await MySqlConnection.connect(_settings);
    _resStatus = ResourceStatus.OpeningUsrInfo;
    notifyListeners();
    User user = await AuthInterface.getUser();
    Results res = await conn.query('select idUsuario from Usuario where email = ?', [user.email]);
    if (res.isEmpty)
      return {'uid': null, 'conn': conn};
    _resStatus = rs;
    notifyListeners();
    return {'uid': int.tryParse(res.elementAt(0)[0].toString()), 'conn': conn};
  }

  Map<String, dynamic> _acResp(bool ok, String msg, {dynamic data}) {
    _resStatus = ok ? ResourceStatus.Ready : ResourceStatus.Error;
    notifyListeners();
    return {'status': ok, 'message': msg, 'data': data};
  }

  Future<Map<String, dynamic>> getResourceList() async {
    assert (_loggedInStatus == AuthStatus.LoggedIn);
    MySqlConnection conn;
    try {
      Map<String, dynamic> uAd = await _getAcUserId(ResourceStatus.GettingRes);
      conn = uAd['conn'];
      if (uAd['uid'] == null)
        return _acResp(false, 'El usuario no existe');
      //Results res = await conn.query('select name, token, color, alimentarAhora, iluminacionEstado, iluminacionAhora, temperActual, temperCalentar, temperEnfriar, phActual from Acuario where idUsuario = ?', [uAd['uid']]);
      Results res = await conn.query('select name, token, color from Acuario where idUsuario = ?', [uAd['uid']]);
      List<AqParams> aquariums = [];
      var rng = new Random();
      for (var row in res) {
        int color = row['color'] | 0xFF000000;
        color ??= 0xff98B7D7;
        aquariums.add(AqParams(
          uuid: row['token'],
          name: row['name'],
          color: color,
          /*op: Operate(
            //temp: row['temperActual'],
            ph: row['phActual'],
            ilumSt: row['iluminacionEstado'],
            calAq: row['temperCalentar'] != 0,
            enfAq: row['temperEnfriar'] != 0,
            onOffIlum: row['iluminacionAhora'] != 0,
            alim: row['alimentarAhora'] != 0,
          ),
          hs: History (
            promHrsAlim: 10 + rng.nextInt(140),
            promTemp: 20 + rng.nextInt(10),
            promIlum: 10 + rng.nextInt(100),
            promPH: 4 + rng.nextInt(6),
          ),*/
          op: Operate(
            temp: 0.0,
            ph: 0.0,
            ilumSt: "",
            calAq: false,
            enfAq: false,
            onOffIlum: false,
            alim: false,
          ),
          hs: History(),
        ));
      }
      return _acResp(true, 'Acuarios cargados!', data: aquariums);
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _acResp(false, "Exception:\n${e.toString()}");
    } finally {
      if (conn != null)
        conn.close();
    }
  }

  Future<Map<String, dynamic>> addResource(String name, String uuid, {int color}) async {
    MySqlConnection conn;
    try {
      Map<String, dynamic> uAd = await _getAcUserId(ResourceStatus.GettingRes);
      conn = uAd['conn'];
      if (uAd['uid'] == null)
        return _acResp(false, 'El usuario no existe');
      var rng = new Random();
      color &= 0xFFFFFF;
      //await conn.query('insert into Acuario (idUsuario, name, token, color, alimentarAhora, iluminacionEstado, iluminacionAhora, temperActual, temperCalentar, temperEnfriar, phActual) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      //    [uAd['uid'], name, uuid, color, false, "APAGADO", false, 20 + rng.nextInt(10), false, false,  4 + rng.nextInt(6)]);
      await conn.query('insert into Acuario (idUsuario, name, token, color) values (?, ?, ?, ?)',
          [uAd['uid'], name, uuid, color]);
      return _acResp(true, 'Acuario Agregado!');
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _acResp(false, "Exception:\n${e.toString()}");
    } finally {
      if (conn != null)
        conn.close();
    }
  }

  Future<Map<String, dynamic>> deleteResource(String uuid) async {
    MySqlConnection conn;
    try {
      Map<String, dynamic> uAd = await _getAcUserId(ResourceStatus.GettingRes);
      conn = uAd['conn'];
      if (uAd['uid'] == null)
        return _acResp(false, 'El usuario no existe');
      await conn.query('delete from Acuario where idUsuario = ? and token = ?', [uAd['uid'], uuid]);
      return _acResp(true, 'Acuario removido!');
    } catch (e) {
      print("Exception handled: ${e.toString()}");
      return _acResp(false, "Exception:\n${e.toString()}");
    } finally {
      if (conn != null)
        conn.close();
    }
  }
}

class DataCustom with ChangeNotifier implements DataInterface {
  String _token;
  bool _updatesOn;
  int _updatePer;
  bool _stopTimer = false;
  int _updCnt = 1;
  int _updCntLast = 0;
  Map<String, PrimData> _dataNeeded;
  final _ioc = new HttpClient()
    ..badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
  Map<String, dynamic> buffer= new Map();

  void init(Map<String, PrimData> dataNeeded, String token, {bool updatesOn = false, int updatePer = 1}) {
    _updatesOn = updatesOn;
    _dataNeeded = dataNeeded;
    _updatePer = updatePer > 1 ? updatePer : 1;
    _token = token;
    Timer.periodic(Duration(seconds: _updatePer), sendEvent);
    _dataNeeded.forEach((key, value) {
      switch(value.type) {
        case dataType.boolT:
          value.lastValue = value.value = false;
          break;
        case dataType.intT:
          value.lastValue = value.value = 0;
          break;
        case dataType.floatT:
          value.lastValue = value.value = 0.0;
          break;
        case dataType.stringT:
          value.lastValue = value.value = "";
      }
    });
  }

  void sendEvent(Timer t) async {
    if(!_updatesOn)
      return;
    if(_stopTimer)
      return;
    _stopTimer = true;
    try {
      final http = new IOClient(_ioc);
      _dataNeeded.forEach((key, value) async {
        String url = CustomAppUrl.getUrl(_token, value.id);
        Response response = await http.get(url);
        if(response.statusCode == 200) {
          List<dynamic> js = json.decode(response.body);
          if(js.isNotEmpty) {
            var responseData = js[0];
            value.lastValue = value.value;
            switch(value.type) {
              case dataType.boolT:
                value.value = responseData != "0";
                break;
              case dataType.intT:
                value.value = int.tryParse(responseData);
                break;
              case dataType.floatT:
                value.value = double.tryParse(responseData);
                break;
              case dataType.stringT:
                value.value = responseData.toString();
            }
          } else {
            print("${value.name}=${response.body}=${value.value}");
          }
        }
        if(value.lastValue != value.value) {
          buffer[key] = value.value;
          _updCnt++;
          print("new: ${value.value} old: ${value.lastValue}");
        }
      });
    } catch (e) {
      print("Exception: $e");
      return;
    } finally {
      _stopTimer = false;
      if(_updCnt != _updCntLast) {
        _updCntLast = _updCnt;
        notifyListeners();
      }
    }
  }

  set updates(bool on) {
    _updatesOn = on;
  }

  Map<String, dynamic> get values {
    Map<String, dynamic> tempBuffer = new  Map<String, dynamic>.from(buffer);
    buffer.clear();
    return tempBuffer;
  }

  set values(Map<String, dynamic> data) {
    _stopTimer = true;
    try {
      final http = new IOClient(_ioc);
      data.forEach((key, dataItem) async {
        if(_dataNeeded.containsKey(key)) {
          PrimData value = _dataNeeded[key];
          String dataValue;
          switch (value.type) {
            case dataType.boolT:
              dataValue = dataItem ? "1" : "0";
              break;
            case dataType.intT:
            case dataType.floatT:
              dataValue = "$dataItem";
              break;
            case dataType.stringT:
              dataValue = value.value;
          }
          String url = CustomAppUrl.getUrl(_token, value.id, value: dataValue);
          Response response = await http.get(url);
          if (response.statusCode == 200) {
            print('$key changed to $dataItem');
          }
        }
      });
    } catch (e) {
      print("Exception: $e");
      return;
    } finally {
      _stopTimer = false;
    }
  }
}
