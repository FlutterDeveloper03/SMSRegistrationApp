// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sms_registration_with_websocket/Models/tbl_dk_user.dart';

class Services {
  static const String MainAddress = 'https://ls.com.tm'; //'http://192.168.1.56:5000';
  static const String MyRoute = '/ls/api';
  static const String WsMainAddress = 'wss://ls.com.tm'; //'http://192.168.1.56:5000';
  static const String WsMyRoute = '/ws/';
  final publicAddress = MainAddress;
  final myRoute = MyRoute;
  final wsPublicAddress = WsMainAddress;
  final wsMyRoute = WsMyRoute;
  static Map<String, String> headers = {};

  void updateCookie(http.Response response) {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      debugPrint('DkPrint SET Cookie: $rawCookie');
      headers['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
  }

//region Auth service

  String _token = '';
  DateTime? tokenExpDate;
  late String requestError;
  TblDkUser? tblDkUser;
  Future<String> getToken(String uName, String uPass, String apiMainAddress) async {
    try {
      String basicAuth = 'Basic ${base64Encode(utf8.encode('$uName:$uPass'))}';
      debugPrint(basicAuth);
      headers['Authorization'] = basicAuth;
      final response = await http.get(Uri.parse('$apiMainAddress/login/?type=user'), headers: headers);
      updateCookie(response);
      if (response.statusCode == 200) {
        debugPrint(response.statusCode.toString());
        dynamic decoded = jsonDecode(response.body);
        _token = decoded['token'].toString();
        tokenExpDate = DateTime.parse(decoded['exp']);
        decoded['user']['UName']=uName;
        decoded['user']['UPass']=uPass;
        tblDkUser = TblDkUser.fromJson(decoded['user']);

        return decoded['token'].toString();
      } else {
        requestError = "Status code = ${response.statusCode}";
      }
    } catch (e) {
      requestError = e.toString();
      throw Exception(e.toString());
    }
    return '';
  }

  Future<void> deleteToken() async {
    _token = '';
    tokenExpDate = null;
  }

  Future<bool> hasToken() async {
    if (_token.isNotEmpty && tokenExpDate!.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      return true;
    }
    return false;
  }

//endregion AuthService

}
