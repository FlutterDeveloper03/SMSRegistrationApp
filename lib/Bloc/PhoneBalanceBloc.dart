// ignore_for_file: file_names

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ussd_service/ussd_service.dart';

//region Events
class PhoneBalanceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetBalanceEvent extends PhoneBalanceEvent{}
//endregion Events


//region States
class PhoneBalanceState extends Equatable {
  @override
  List<Object> get props => [];
}

class PhoneBalanceInitState extends PhoneBalanceState{}
class GettingBalanceState extends PhoneBalanceState{}
class BalanceGotState extends PhoneBalanceState{
  final String balance;

  BalanceGotState(this.balance);

  String get getBalance=>balance;

  @override
  List<Object> get props => [balance];
}
//endregion States

//region Bloc
class PhoneBalanceBloc extends Bloc<PhoneBalanceEvent,PhoneBalanceState>{
  String _balance='';

  PhoneBalanceBloc() : super(PhoneBalanceInitState()){
    on<GetBalanceEvent>(_onGetBalance);
  }

  @override
  void onTransition(Transition<PhoneBalanceEvent, PhoneBalanceState> transition) {
    super.onTransition(transition);
    debugPrint(transition.toString());
  }

  void _onGetBalance(GetBalanceEvent event, Emitter<PhoneBalanceState> emit)async{
    emit(GettingBalanceState());
    if (await Permission.phone.request().isGranted) {
      int sim = 1;
      String code = '*0800#';
      try {
        _balance = await UssdService.makeRequest(
          sim,
          code,
          const Duration(seconds: 10), // timeout (optional) - default is 10 seconds
        );
      } catch (e) {
        debugPrint("error! code: ${e.hashCode} - message: ${e.toString()}");
      }
      _balance = '${_balance.replaceAll(RegExp(r'[^0-9|,]'), '')} TMT';
      debugPrint(_balance);
      emit(BalanceGotState(_balance));
    } else if (await Permission.phone.isPermanentlyDenied) {
      openAppSettings();
      emit(PhoneBalanceInitState());
    }
  }
}
//endregion Bloc



