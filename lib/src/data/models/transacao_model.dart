import 'package:equatable/equatable.dart';

/// Enum de despesa ou receita
enum TransactionType { despesa, receita }

/// representa uma transação financeira
class Transaction extends Equatable {
  final int? id; 
  final String description; 
  final double amount; 
  final DateTime date; 
  final int categoryId; 
  final TransactionType type; 

  const Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.categoryId,
    required this.type,
  });

  @override
  List<Object?> get props => [id, description, amount, date, categoryId, type];

  // converte um objeto Transaction em um map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(), 
      'categoryId': categoryId,
      'type': type.name, 
    };
  }

  /// objeto transaction a partir de um map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), //converte para date time
      categoryId: map['categoryId'],
      type: TransactionType.values.byName(map['type']), // para enum
    );
  }
}