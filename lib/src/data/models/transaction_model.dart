import 'package:equatable/equatable.dart';

/// Enum para definir o tipo da transacao despesa ou receita
enum TransactionType { expense, income }

/// Representa uma transação financeira.
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

  /// Converte um objeto Transaction em um Map para salvar no banco.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(), // Converte DateTime para string
      'categoryId': categoryId,
      'type': type.name, 
    };
  }

  /// Cria um objeto Transaction a partir de um Map vindo do banco.
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']), // Converte a string de volta para DateTime
      categoryId: map['categoryId'],
      type: TransactionType.values.byName(map['type']), // Converte a string de volta para o enum
    );
  }
}