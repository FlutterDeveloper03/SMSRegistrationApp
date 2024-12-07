// ignore_for_file: non_constant_identifier_names, file_names

import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sms_registration_with_websocket/Helpers/dbHelper.dart';
import 'package:sms_registration_with_websocket/Models/tbl_dk_user.dart';
import '../Services/Services.dart';

//region Events
/////////////////// Events ////////////////

abstract class AuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthLogInEvent extends AuthEvent {
  final String uName;
  final String uPass;

  AuthLogInEvent(this.uName, this.uPass);

  @override
  List<Object> get props => [uName, uPass];

  @override
  String toString() => 'LoginBtnPressedEvent';
}

class AuthLoggedInEvent extends AuthEvent {
  final String token;

  AuthLoggedInEvent({required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'LoggedIn { token: $token }';
}

class AuthLogOutEvent extends AuthEvent {}

//endregion Events

//region States
/////////////////// States ////////////////

abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}
class AuthSuccess extends AuthState {
  final String _token;
  final String _uName;
  final String _uPass;
  final DateTime _tokenExpirationDate;
  final TblDkUser _user;
  final String apiAddress;

  AuthSuccess(this._token, this._tokenExpirationDate, this._user,
      this.apiAddress, this._uName, this._uPass);

  String get getToken => _token;
  TblDkUser get getUser => _user;
  String get getUName => _uName;
  String get getUPass => _uPass;
  String get getApiAddress => apiAddress;
  DateTime get getTokenExpDate => _tokenExpirationDate;

  @override
  List<Object> get props => [_token, _user,_uName,_uPass,_tokenExpirationDate,apiAddress];

  @override
  String toString() => 'AuthSuccessState { token: $_token }';
}
class AuthFailure extends AuthState {
  final String errorStatus;

  AuthFailure(this.errorStatus);

  String get getErrorStatus => errorStatus;

  @override
  List<Object> get props => [errorStatus];

  @override
  String toString() => 'AuthFailureState { errorStatus: $errorStatus }';
}
class AuthInProgress extends AuthState {}

//endregion States

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Services _srv;
  late String _uName;
  late String _uPass;
  AuthBloc(this._srv) : super(AuthInitial()){
    on<AuthLogInEvent>(_onAutLoginEvent);
    on<AuthLogOutEvent>(_onAuthLogOutEvent);
  }

  @override
  void onTransition(Transition<AuthEvent, AuthState> transition) {
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void _onAutLoginEvent(AuthLogInEvent event, Emitter<AuthState> emit) async {
    emit(AuthInProgress());
    try {
      _uName = event.uName;
      _uPass = event.uPass;
      String token = await _srv.getToken(
          _uName, _uPass, _srv.publicAddress + _srv.myRoute);
      debugPrint('DkPrint token is $token');
      bool HasToken = await _srv.hasToken();

      if (HasToken) {
        debugPrint('DkPrint HasToken=$HasToken');
        TblDkUser tbl_dk_user;
        if (_srv.tblDkUser != null) {
          tbl_dk_user = TblDkUser(
              UId:_srv.tblDkUser!.UId,
              UGuid:_srv.tblDkUser!.UGuid,
              CId:_srv.tblDkUser!.CId,
              DivId:_srv.tblDkUser!.DivId,
              RpAccId:_srv.tblDkUser!.RpAccId,
              ResPriceGroupId:_srv.tblDkUser!.ResPriceGroupId,
              URegNo:_srv.tblDkUser!.URegNo,
              UFullName:_srv.tblDkUser!.UFullName,
              UName:_srv.tblDkUser!.UName,
              UEmail:_srv.tblDkUser!.UEmail,
              UPass:_srv.tblDkUser!.UPass,
              UShortName:_srv.tblDkUser!.UShortName,
              EmpId:_srv.tblDkUser!.EmpId,
              UTypeId:_srv.tblDkUser!.UTypeId,
              AddInf1:_srv.tblDkUser!.AddInf1,
              AddInf2:_srv.tblDkUser!.AddInf2,
              AddInf3:_srv.tblDkUser!.AddInf3,
              AddInf4:_srv.tblDkUser!.AddInf4,
              AddInf5:_srv.tblDkUser!.AddInf5,
              AddInf6:_srv.tblDkUser!.AddInf6
          );
          debugPrint('DkPrint try insert to db');
          int count = await DbHelper.insertUser('tbl_dk_user', tbl_dk_user);
          debugPrint('DkPrint insert count=$count. Try to yield AuthSuccess');
          emit(AuthSuccess(token, _srv.tokenExpDate!, _srv.tblDkUser!,
              _srv.publicAddress, _uName, _uPass));
        } else {
          emit(AuthFailure(_srv.requestError));
        }
      } else {
        emit(AuthFailure(_srv.requestError));
      }
    } catch (_) {
      emit(AuthFailure(_srv.requestError));
    }
  }

  void _onAuthLogOutEvent(AuthLogOutEvent event, Emitter<AuthState> emit)async{
    _srv.deleteToken();
    emit(AuthInitial());
  }
}
