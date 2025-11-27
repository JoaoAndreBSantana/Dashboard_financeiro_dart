import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart'; 
import '../../logic/blocs/category_bloc.dart';
import '../../logic/blocs/transaction_bloc.dart';
import '../../logic/states/category_state.dart';
import '../../logic/states/transaction_state.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/summary_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, transactionState) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            if (transactionState is TransactionLoaded && categoryState is CategoryLoaded) {
              if (transactionState.transactions.isEmpty) {
                return const Center(child: Text('Adicione transações para ver o dashboard.'));
              }

              
              double totalIncome = 0;
              double totalExpenses = 0;
              for (var transaction in transactionState.transactions) {
                if (transaction.type == TransactionType.income) {
                  totalIncome += transaction.amount;
                } else {
                  totalExpenses += transaction.amount;
                }
              }
              final double balance = totalIncome - totalExpenses;

              
              return ListView(
                padding: const EdgeInsets.all(12.0),
                children: [
                
                  Row(
                    children: [
                      SummaryCard(
                        title: 'Receitas',
                        amount: totalIncome,
                        color: Colors.green.shade400,
                        icon: Icons.arrow_upward,
                      ),
                      const SizedBox(width: 12),
                      SummaryCard(
                        title: 'Despesas',
                        amount: totalExpenses,
                        color: Colors.red.shade400,
                        icon: Icons.arrow_downward,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Saldo: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(balance)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: balance >= 0 ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legenda de Despesas',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          
                          Wrap(
                            spacing: 16.0, 
                            runSpacing: 8.0,  
                            children: categoryState.categories
                                .where((cat) => cat.name != 'Salário') 
                                .map((category) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: category.colorValue,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // O nome da categoria
                                      Text(category.name),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                 

                  const SizedBox(height: 24),

                 
                  Text(
                    'Gráfico de Despesas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  CategoryPieChart(
                    transactions: transactionState.transactions,
                    categories: categoryState.categories,
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }
}