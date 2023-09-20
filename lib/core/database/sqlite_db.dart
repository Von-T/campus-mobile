// import 'dart:async';
//
// import 'package:flutter/widgets.dart';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class SqliteDatabase {
//   var database;
//
//   /// create (or open if it already exists) the database and where it will be located
//   void initializeDB() async {
//     // Avoid errors caused by flutter upgrade
//     WidgetsFlutterBinding.ensureInitialized();
//
//     // Create (or open if it already exists) the database and store the reference in 'database'
//     database = openDatabase(
//       // Set the path to the database to store persistent data at
//       join(await getDatabasesPath(), 'sqlite_database.db'),
//     );
//   }
// }
