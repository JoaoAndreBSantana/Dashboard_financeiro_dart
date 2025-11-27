import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Category? category;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.type == TransactionType.income
        ? Colors.green.shade400
        : Colors.red.shade400;

    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yy');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        // Ícone da Categoria
        leading: CircleAvatar(
          backgroundColor: category?.colorValue ?? Colors.grey,
          child: Icon(
            category != null ? IconData(category!.iconCodePoint, fontFamily: 'MaterialIcons') : Icons.help_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
        // Descriçao e Nome da Categoria
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(category?.name ?? 'Sem Categoria'),
        // Valor e Data
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${transaction.type == TransactionType.income ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(transaction.date),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}