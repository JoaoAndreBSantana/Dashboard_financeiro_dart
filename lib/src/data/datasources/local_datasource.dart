import '../models/categoria_model.dart';
import '../models/transacao_model.dart';
import 'local/database_helper.dart';
import 'package:flutter/material.dart'; 


class LocalDataSource {
  final dbHelper = DatabaseHelper.instance;

 

  //inserir
  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  //buscar
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

 

  /// Inserir
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  //buscar
  Future<List<Transaction>> getAllTransactions({DateTimeRange? dateRange}) async {
    final db = await dbHelper.database;
    
    String? where;
    List<dynamic>? whereArgs;

    if (dateRange != null) {
      where = 'date >= ? AND date <= ?';
      
      whereArgs = [
        dateRange.start.toIso8601String(),
        dateRange.end.add(const Duration(days: 1)).toIso8601String(),
      ];
    }

    final maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
      where: where,
      whereArgs: whereArgs,
    );
    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  /// deleta uma transação por id
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}