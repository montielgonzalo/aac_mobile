import 'package:flutter/foundation.dart';
import 'package:aac_mobile/tools/dataService/aqData.dart';

enum UserRole {
  admin,
  regular,
  machine,
  guest
}

extension UserRoleExtNum on UserRole {
  static const values = [1, 2, 3, 4];
  int get value => values[this.index];
}

extension UserRoleExtStr on UserRole {
  static const names = ["admin", "regular", "machine", "guest"];
  String get name => names[this.index];
}

class User {
  int id;
  String email;
  String password;
  String name;
  String role;
  String token;
  int duration;
  String renewalToken;

  User({this.id, this.email, this.password, this.name, this.role, this.token, this.duration, this.renewalToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id'],
        email: json['email'],
        password: json['password'],
        name: json['name'],
        role: json['role'],
        token: json['access_token'],
        duration: json['duration'],
        renewalToken: json['renewal_token']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'password': password,
    'name': name,
    'role': role,
    'access_token': token,
    'duration': duration,
    'renewal_token': renewalToken,
  };
}



class UserProvider with ChangeNotifier {
  User _user = new User();

  User get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }
}