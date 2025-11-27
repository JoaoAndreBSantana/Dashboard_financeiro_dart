import '../datasources/local_datasource.dart';
import '../models/transaction_model.dart';
import 'package:flutter/material.dart'; 


class TransactionRepository {
  
  final LocalDataSource localDataSource;

  TransactionRepository({required this.localDataSource});

  /// Busca todas as transacoes passando o filtro de data para o datasource, pois so ele tem acesso ao banco local
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