// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:sms_registration_with_websocket/Models/tbl_dk_customer.dart';

class ProviderModel with ChangeNotifier{

  List<TblDkCustomer> _customers=[];
  List<TblDkCustomer> get getCustomers=>_customers;
  set setCustomers(List<TblDkCustomer> customers){
    _customers = customers;
    notifyListeners();
  }
}