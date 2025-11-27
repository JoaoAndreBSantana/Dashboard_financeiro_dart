import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'local/database_helper.dart';
import 'package:flutter/material.dart'; 

///classe responsável por todas as operações de crud no banco
class LocalDataSource {
  final dbHelper = DatabaseHelper.instance;

 

  /// Insere uma nova categoria no banco de dados.
  Future<int> insertCategory(Category category) async {
    final db = await dbHelper.database;
    return await db.insert('categories', category.toMap());
  }

  /// Busca todas as categorias do banco de dados.
  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

 

  /// Insere uma nova transação no banco de dados.
  Future<int> insertTransaction(Transaction transaction) async {
    final db = await dbHelper.database;
    return await db.insert('transactions', transaction.toMap());
  }

  /// Busca todas as transacoes filtrando por um intervalo de datas
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

  /// feleta uma transação por id
  Future<int> deleteTransaction(int id) async {
    final db = await dbHelper.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}