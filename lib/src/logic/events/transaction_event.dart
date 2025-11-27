import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../../data/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}


class LoadTransactions extends TransactionEvent {
  final DateTimeRange? dateRange;

  const LoadTransactions({this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}

//evento para adicionar uma nova transacao
class AddTransaction extends TransactionEvent {
  final Transaction transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object> get props => [transaction];
}

//evento para deletar uma transaçao que já existe
class DeleteTransaction extends TransactionEvent {
  final int transactionId;

  const DeleteTransaction(this.transactionId);

  @override
  List<Object> get props => [transactionId];
}