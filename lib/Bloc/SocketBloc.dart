// ignore_for_file: file_names

import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_registration_with_websocket/Models/RespDkReceivedCode.dart';
import 'package:sms_registration_with_websocket/Services/Services.dart';
import 'package:web_socket_channel/io.dart';

//region Events
class SocketEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class ConnectToSocketEvent extends SocketEvent{
  final String token;

  ConnectToSocketEvent(this.token);

  @override
  List<Object> get props => [token];
}
class DisconnectFromSocketEvent extends SocketEvent{}
//endregion Events

//region States
class SocketState extends Equatable {
  @override
  List<Object> get props => [];
}
class SocketInitState extends SocketState{}
class ConnectingToSocketState extends SocketState{}
class ConnectionErrorState extends SocketState{
  final String errorText;

  ConnectionErrorState(this.errorText);

  String get getErrorText=>errorText;

  @override
  List<Object> get props => [errorText];
}
class ConnectedState extends SocketState{}
class DataReceived extends SocketState{
  final RespDkReceivedCode receivedData;

  DataReceived(this.receivedData);

  RespDkReceivedCode get getReceivedData=>receivedData;

  @override
  List<Object> get props => [receivedData];
}
//endregion States

//region Bloc
class SocketBloc extends Bloc<SocketEvent,SocketState>{
  final Services _srv;
  Map<String, String> headers = {};

  SocketBloc(this._srv) : super(SocketInitState()){
    on<ConnectToSocketEvent>(_onConnectToSocket);
    on<DisconnectFromSocketEvent>(_onDisconnectFromSocket);
  }

  @override
  void onTransition(Transition<SocketEvent, SocketState> transition) {
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void _onConnectToSocket(ConnectToSocketEvent event,Emitter<SocketState> emit)async{
    bool connected=false;

    emit(ConnectingToSocketState());
    if (event.token.isNotEmpty){
      headers['token']=event.token;
      try{
        final socket = IOWebSocketChannel.connect('${_srv.wsPublicAddress}${_srv.wsMyRoute}sms-register/');
        socket.stream.listen((message){
          debugPrint('DkPrint Socket Connected');

          if (message.toString()=="connected send valid jwt"){
            socket.sink.add({"token":event.token});
            if (!connected){
              emit(ConnectedState());
            }
          } else{
            try{
              RespDkReceivedCode receivedCode=RespDkReceivedCode.fromJson(message);
              log("DkPrint: ${receivedCode.phone_number}");
              emit(DataReceived(receivedCode));
            } catch(e){
              debugPrint('DkPrintError: ${e.toString()}');
            }
          }
        },
        onError: (error){
          debugPrint(error);
          emit(ConnectionErrorState(error.toString()));
          connected=false;
        },
        onDone: (){
          //TODO OnDone
        }

        );

        // socket.on('event',(data){
        //   RespDkReceivedCode _resp=RespDkReceivedCode.fromJson(data);
        //   emit(DataReceived(_resp));
        //   Future.delayed(Duration(seconds: 1));
        //   emit(ConnectedState());
        // });
        // socket.onConnectError((data) => ConnectionErrorState(data.toString()));
        // socket.connect();

      } catch (e){
        debugPrint(e.toString());
        emit(ConnectionErrorState(e.toString()));
      }
    } else {
      emit(ConnectionErrorState('You should login before connect!'));
    }
  }

  void _onDisconnectFromSocket(DisconnectFromSocketEvent event,Emitter<SocketState> emit)async{

  }

}


//endregion Bloc
