import 'package:flutter/material.dart';

class UserInfo{
  final String username;
  final String password;

  UserInfo({required this.username, required this.password});

  factory UserInfo.fromJson(Map<String, dynamic> json){
    return UserInfo(
        username: json['username'],
        password: json['password']
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'username': username,
      'password': password
    };
  }
}