// ignore_for_file: non_constant_identifier_names

import 'package:sms_registration_with_websocket/Models/Model.dart';

class TblDkUser extends Model{
  final int UId;
  final String UGuid;
  final int CId;
  final int DivId;
  final int RpAccId;
  final int ResPriceGroupId;
  final String URegNo;
  final String UFullName;
  final String UName;
  final String UEmail;
  final String UPass;
  final String UShortName;
  final int EmpId;
  final int UTypeId;
  final String AddInf1;
  final String AddInf2;
  final String AddInf3;
  final String AddInf4;
  final String AddInf5;
  final String AddInf6;

  TblDkUser({required this.UId,required this.UGuid,required this.CId,required this.DivId,required this.RpAccId,required this.ResPriceGroupId,
            required this.URegNo,required this.UFullName,required this.UName,required this.UEmail,required this.UPass,required this.UShortName,
            required this.EmpId,required this.UTypeId,required this.AddInf1,required this.AddInf2,required this.AddInf3,required this.AddInf4,
            required this.AddInf5,required this.AddInf6});

  @override
  Map<String,dynamic> toMap()=>{
    'UId':UId,
    'UGuid':UGuid,
    'CId':CId,
    'DivId':DivId,
    'RpAccId':RpAccId,
    'ResPriceGroupId':ResPriceGroupId,
    'URegNo':URegNo,
    'UFullName':UFullName,
    'UName':UName,
    'UEmail':UEmail,
    'UPass':UPass,
    'UShortName':UShortName,
    'EmpId':EmpId,
    'UTypeId':UTypeId,
    'AddInf1':AddInf1,
    'AddInf2':AddInf2,
    'AddInf3':AddInf3,
    'AddInf4':AddInf4,
    'AddInf5':AddInf5,
    'AddInf6':AddInf6,
  };

  static TblDkUser fromMap(Map<String,dynamic> map)=>TblDkUser(
      UId:map['UId'],
      UGuid:map['UGuid'].toString(),
      CId:map['CId'],
      DivId:map['DivId'],
      RpAccId:map['RpAccId'],
      ResPriceGroupId:map['ResPriceGroupId'],
      URegNo:map['URegNo'].toString(),
      UFullName:map['UFullName'].toString(),
      UName:map['UName'].toString(),
      UEmail:map['UEmail'].toString(),
      UPass:map['UPass'].toString(),
      UShortName:map['UShortName'].toString(),
      EmpId:map['EmpId'],
      UTypeId:map['UTypeId'],
      AddInf1:map['AddInf1'].toString(),
      AddInf2:map['AddInf2'].toString(),
      AddInf3:map['AddInf3'].toString(),
      AddInf4:map['AddInf4'].toString(),
      AddInf5:map['AddInf5'].toString(),
      AddInf6:map['AddInf6'].toString(),
  );

  TblDkUser.fromJson(Map<String,dynamic> json)
    :UId=json['UId'] ?? 0,
  UGuid=json['UGuid'] ?? '',
  CId=json['CId'] ?? 0,
  DivId=json['DivId'] ?? 0,
  RpAccId=json['RpAccId'] ?? 0,
  ResPriceGroupId=json['ResPriceGroupId'] ?? 0,
  URegNo=json['URegNo'] ?? '',
  UFullName=json['UFullName'] ?? '',
  UName=json['UName'] ?? '',
  UEmail=json['UEmail'] ?? '',
  UPass=json['UPass'] ?? '',
  UShortName=json['UShortName'] ?? '',
  EmpId=json['EmpId'] ?? 0,
  UTypeId=json['UTypeId'] ?? 0,
  AddInf1=json['AddInf1'] ?? '',
  AddInf2=json['AddInf2'] ?? '',
  AddInf3=json['AddInf3'] ?? '',
  AddInf4=json['AddInf4'] ?? '',
  AddInf5=json['AddInf5'] ?? '',
  AddInf6=json['AddInf6'] ?? '';

  Map<String,dynamic> toJson()=>{
    'UId':UId,
    'UGuid':UGuid,
    'CId':CId,
    'DivId':DivId,
    'RpAccId':RpAccId,
    'ResPriceGroupId':ResPriceGroupId,
    'URegNo':URegNo,
    'UFullName':UFullName,
    'UName':UName,
    'UEmail':UEmail,
    'UPass':UPass,
    'UShortName':UShortName,
    'EmpId':EmpId,
    'UTypeId':UTypeId,
    'AddInf1':AddInf1,
    'AddInf2':AddInf2,
    'AddInf3':AddInf3,
    'AddInf4':AddInf4,
    'AddInf5':AddInf5,
    'AddInf6':AddInf6,
  };
}
