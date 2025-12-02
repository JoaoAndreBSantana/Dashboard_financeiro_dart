import '../datasources/local_datasource.dart';
import '../models/transacao_model.dart';
import 'package:flutter/material.dart'; 


class TransactionRepository {
  
  final LocalDataSource localDataSource;

  TransactionRepository({required this.localDataSource});

  
  Future<List<Transaction>> getAllTransactions({DateTimeRange? dateRange}) {
    return localDataSource.getAllTransactions(dateRange: dateRange);
  }

  /// Adiciona uma nova transação.
  Future<void> addTransaction(Transaction transaction) async {
    await localDataSource.insertTransaction(transaction);
   
  }

  /// Deleta uma transação.
  Future<void> deleteTransaction(int id) async {
    await localDataSource.deleteTransaction(id);
   
  }
}