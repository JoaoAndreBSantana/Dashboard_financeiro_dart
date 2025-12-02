import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../data/models/categoria_model.dart';
import '../../data/models/transacao_model.dart'; 
import '../../logica/blocs/categoria_bloc.dart';
import '../../logica/blocs/transacao_bloc.dart';
import '../../logica/states/categoria_state.dart';
import '../../logica/states/transacao_state.dart';
import '../widgets/grafico_pizza_categoria.dart';
import '../widgets/cartao_resumo.dart';


class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // ouve o bloco de trnsacao para obter o estado
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, transactionState) {
      
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            // valida se transacao e categoria foram carregadas
            if (transactionState is TransactionLoaded && categoryState is CategoryLoaded) {
              
              if (transactionState.transactions.isEmpty) {
                return const Center(child: Text('Adicione transações para ver o dashboard.'));
              }

              
              //variaveis para guardar os totais
              double totalIncome = 0;
              double totalExpenses = 0;
              
              for (var transaction in transactionState.transactions) {
                // verifica o tipo da transação para somar 
                if (transaction.type == TransactionType.receita) {
                  totalIncome += transaction.amount;
                } else {
                  totalExpenses += transaction.amount;
                }
              }
              // calcula o saldo final
              final double balance = totalIncome - totalExpenses;

              

              // Usa um ListView para que a tela seja rolável.
              return ListView(
                padding: const EdgeInsets.all(12.0),
                children: [
                  // Linha com os cards de resumo (Receitas e Despesas).
                  Row(
                    children: [
                      // cartao resumo receitas e despesas
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
                  // Card para mostrar o saldo total.
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

                  //card que mostra a legenda das cores 
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
                            // pega a lista de categorias do bloc
                            children: categoryState.categories
                               
                                .where((cat) => cat.name != 'Salário') 
                                //  cria um widget para cada categoria restante
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
                                      // O nome da categoria.
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