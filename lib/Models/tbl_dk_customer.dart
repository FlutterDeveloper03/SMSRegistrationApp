// ignore_for_file: non_constant_identifier_names

import 'Model.dart';

class TblDkCustomer extends Model{
  final String Key;
  final String CustomerPhoneNo;
  final String VerifyCode;
  final DateTime Date;
  final int SmsStatus;  //0=failed; 1=sending; 2=sent; 3=delivered;
  final String Desc;

  TblDkCustomer({required this.Key,required this.CustomerPhoneNo,required this.VerifyCode,required this.Date,
    required this.SmsStatus,required this.Desc});

  @override
  Map<String, dynamic> toMap(){
    Map<String,dynamic> map={
      'Key':Key,
      'CustomerPhoneNo':CustomerPhoneNo,
      'VerifyCode':VerifyCode,
      'Date':Date.millisecondsSinceEpoch,
      'IsSentSuccess':SmsStatus,
      'Desc':Desc
    };
    return map;
  }

  static TblDkCustomer fromMap(Map<String,dynamic> map){
    return TblDkCustomer(
        Key:map['Key'] ?? '',
        CustomerPhoneNo:map['CustomerPhoneNo']?.toString() ?? '',
        VerifyCode:map['VerifyCode']?.toString() ?? '' ,
        Date:DateTime.fromMillisecondsSinceEpoch(map['Date']),
        SmsStatus:map['IsSentSuccess'],
        Desc:map['Desc']
    );
  }
}