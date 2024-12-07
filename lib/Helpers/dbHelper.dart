// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sms_registration_with_websocket/Models/Model.dart';

abstract class DbHelper {
  static const _dbName = "dbSMSRegistrationApp.db";
  static get _dbVersion => 1;
  static Database? _db;

  static Future<void> init() async {
    if (_db != null) {
      return;
    }

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _dbName);
    debugPrint('DkPrint Path is:$path');
    _db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE tbl_dk_user(
            UId INTEGER PRIMARY KEY NOT NULL,
            UGuid String NULL,
            CId INT NULL,
            DivId INT NULL,
            RpAccId INT NULL,
            ResPriceGroupId INT NULL,
            URegNo String NULL,
            UFullName String NULL,
            UName String NULL,
            UEmail String NULL,
            UPass String NULL,
            UShortName String NULL,
            EmpId INT NULL,
            UTypeId INT NULL,
            AddInf1 String NULL,
            AddInf2 String NULL,
            AddInf3 String NULL,
            AddInf4 String NULL,
            AddInf5 String NULL,
            AddInf6 String NULL
            )
          ''');
    await db.execute('''
          CREATE TABLE tbl_dk_customer(
            CustomerId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            Key String NULL,
            CustomerPhoneNo String NULL,
            VerifyCode String NULL,
            Date DATETIME NULL,
            IsSentSuccess INT NULL,
            Desc String NULL
            )
          ''');

    debugPrint('DkPrint Database is created');
  }

  static Future<int?> rowCount(String table) async =>
      Sqflite.firstIntValue(await _db!.rawQuery('Select Count(*) FROM $table'));

  static Future<List<Map<String, dynamic>>> queryAllRows(String table) async =>
      await _db!.query(table);

  static Future<Map<String, dynamic>> queryFirstRow(String table) async =>
      (await _db!.query(table, limit: 1))[0];

  static Future<int> insert(String table, Model model) async =>
      await _db!.insert(table, model.toMap());

  static Future<int> insertUser(String table, Model model) async {
    await _db!.delete('tbl_dk_user');
    return await _db!.insert(table, model.toMap());
  }

  static Future<int> insertUpdateRowById(String table, Model model, String idColumnName, int id) async {
    try {
      int? count = Sqflite.firstIntValue(await _db!.rawQuery('SELECT COUNT(*) FROM $table WHERE $idColumnName=$id'));
      if (count != null && count > 0) {
        return _db!.update(table, model.toMap(), where: '$idColumnName=$id');
      }
      return await _db!.insert(table, model.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<int> insertUpdateRowByKey(String table, Model model, String keyColumnName, String key) async {
    try {
      int count = Sqflite.firstIntValue(await _db!.rawQuery('SELECT COUNT(*) FROM $table WHERE $keyColumnName=\'$key\'')) ?? 0;
      if (count > 0) {
        return _db!.update(table, model.toMap(), where: '$keyColumnName=\'$key\'');
      } else {
        return await _db!.insert(table, model.toMap());
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<int> update(String table, String columnId, Model model) async =>
      await _db!.update(table, model.toMap(),
          where: '$columnId = ?', whereArgs: [model.toMap()[columnId]]);

  static Future<int> delete(String table, String columnId, Model model) async =>
      await _db!.delete(table,
          where: '$columnId = ?', whereArgs: [model.toMap()[columnId]]);


}
