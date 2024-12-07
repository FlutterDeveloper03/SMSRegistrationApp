// ignore_for_file: file_names

import 'package:another_telephony/telephony.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_registration_with_websocket/Helpers/dbHelper.dart';
import 'package:sms_registration_with_websocket/Models/tbl_dk_customer.dart';

//region Events
class SmsSenderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SendSmsEvent extends SmsSenderEvent {
  final String key;
  final String phoneNumber;
  final String verifyCode;

  SendSmsEvent(this.key, this.phoneNumber, this.verifyCode);

  @override
  List<Object> get props => [key, phoneNumber, verifyCode];
}
//endregion events

//region States
class SmsSenderState extends Equatable {
  @override
  List<Object> get props => [];
}

class SmsSenderInitialState extends SmsSenderState {}

class SendingSmsState extends SmsSenderState {
  final TblDkCustomer _customer;

  SendingSmsState(this._customer);

  TblDkCustomer get getCustomer => _customer;

  @override
  List<Object> get props => [_customer];
}

class ErrorSendingSmsState extends SmsSenderState {
  final TblDkCustomer _customer;
  final String errorStr;

  ErrorSendingSmsState(this._customer, this.errorStr);

  TblDkCustomer get getCustomer => _customer;

  String get getErrorStr => errorStr;

  @override
  List<Object> get props => [_customer, errorStr];
}

class SmsSentState extends SmsSenderState {
  final TblDkCustomer _customer;

  SmsSentState(this._customer);

  TblDkCustomer get getCustomer => _customer;

  @override
  List<Object> get props => [_customer];
}

class SmsDeliveredState extends SmsSenderState {
  final TblDkCustomer _customer;

  SmsDeliveredState(this._customer);

  TblDkCustomer get getCustomer => _customer;

  @override
  List<Object> get props => [_customer];
}
//endregion States

//region Bloc
class SmsSenderBloc extends Bloc<SmsSenderEvent, SmsSenderState> {
  final Telephony _telephony = Telephony.instance;

  SmsSenderBloc() : super(SmsSenderInitialState()) {
    on<SendSmsEvent>(_onSendSms);
  }

  void _onSendSms(SendSmsEvent event, Emitter<SmsSenderState> emit) async {
    if (await Permission.sms.request().isGranted) {
      if (event.phoneNumber.isNotEmpty) {
        try {
          TblDkCustomer customer = TblDkCustomer(
              Key: event.key, CustomerPhoneNo: event.phoneNumber, VerifyCode: event.verifyCode, Date: DateTime.now(), SmsStatus: 1, Desc: '');
          DbHelper.insertUpdateRowByKey('tbl_dk_customer', customer, 'Key', customer.Key);
          emit(SendingSmsState(customer));
        } catch (e) {
          TblDkCustomer customer = TblDkCustomer(
              Key: event.key,
              CustomerPhoneNo: event.phoneNumber,
              VerifyCode: event.verifyCode,
              Date: DateTime.now(),
              SmsStatus: 1,
              Desc: e.toString());
          debugPrint('DkPrintError Error on sending sms to ${event.phoneNumber}');
          emit(ErrorSendingSmsState(customer, e.toString()));
        }
        try {
          listener(SendStatus status) {
            if (status == SendStatus.DELIVERED) {
              TblDkCustomer customer = TblDkCustomer(
                  Key: event.key,
                  CustomerPhoneNo: event.phoneNumber,
                  VerifyCode: event.verifyCode,
                  Date: DateTime.now(),
                  SmsStatus: 3,
                  Desc: '');
              DbHelper.insertUpdateRowByKey('tbl_dk_customer', customer, 'Key', customer.Key);
              emit(SmsDeliveredState(customer));
            }
          }
          _telephony.sendSms(
              to: event.phoneNumber, message: 'Lomay sowda programmasyna agza bolmak kody: ${event.verifyCode}', statusListener: listener);

          TblDkCustomer customer = TblDkCustomer(
              Key: event.key, CustomerPhoneNo: event.phoneNumber, VerifyCode: event.verifyCode, Date: DateTime.now(), SmsStatus: 2, Desc: '');
          DbHelper.insertUpdateRowByKey('tbl_dk_customer', customer, 'Key', customer.Key);
          emit(SmsSentState(customer));
        } catch (e) {
          TblDkCustomer customer = TblDkCustomer(
              Key: event.key,
              CustomerPhoneNo: event.phoneNumber,
              VerifyCode: event.verifyCode,
              Date: DateTime.now(),
              SmsStatus: 0,
              Desc: e.toString());
          debugPrint('DkPrintError Error on sending sms to ${event.phoneNumber}');
          emit(ErrorSendingSmsState(customer, e.toString()));
        }
      } else {
        debugPrint('DkPrintError Phone Number is empty');
        TblDkCustomer customer = TblDkCustomer(
            Key: event.key,
            CustomerPhoneNo: event.phoneNumber,
            VerifyCode: event.verifyCode,
            Date: DateTime.now(),
            SmsStatus: 0,
            Desc: 'Yalnyslyk! Telefon belgisi yok');
        DbHelper.insertUpdateRowByKey('tbl_dk_customer', customer, 'Key', customer.Key);
        emit(ErrorSendingSmsState(customer, 'Yalnyslyk! Telefon belgisi yok'));
      }
    } else {
      debugPrint('DkPrintError Cant access sms permission');
      TblDkCustomer customer = TblDkCustomer(
          Key: event.key,
          CustomerPhoneNo: event.phoneNumber,
          VerifyCode: event.verifyCode,
          Date: DateTime.now(),
          SmsStatus: 0,
          Desc: 'Yalnyslyk! Sms ibermek rugsady yok');
      debugPrint('DkPrintError Error on sending sms to ${event.phoneNumber}');
      DbHelper.insertUpdateRowByKey('tbl_dk_customer', customer, 'Key', customer.Key);
      emit(ErrorSendingSmsState(customer, 'Yalnyslyk! Sms ibermek rugsady yok'));
    }
  }
}
//endregion Bloc
