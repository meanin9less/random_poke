import 'package:flutter/material.dart';

class Token extends ChangeNotifier{
  String? _refreshToken;
  String? _accessToken;

  String get refreshToken => _refreshToken!;

  String get accessToken => _accessToken!;

  set refreshToken(String value) {
    _refreshToken = value;
  }

  set accessToken(String value) {
    _accessToken = value;
  }
}