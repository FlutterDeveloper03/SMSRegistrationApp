// ignore_for_file: file_names

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SocketProvider{
  late final WebSocketChannel _webSocket;

  SocketProvider():_webSocket = WebSocketChannel.connect(Uri.parse('wss://ls.com.tm/elec/ws/sms-register/'));


  Stream get websocket=>_webSocket.stream;


  void openSocket(String token){
    debugPrint('DkPrintJson${jsonEncode({'token':token})}');
    _webSocket.sink.add(
        jsonEncode({'token':token})
    );
  }

  void closeSocket(){
    _webSocket.sink.close();
  }
}