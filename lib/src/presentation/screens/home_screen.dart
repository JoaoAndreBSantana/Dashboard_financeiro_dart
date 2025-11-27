import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/category_model.dart';
import '../../data/models/transaction_model.dart'; 
import '../../logic/blocs/category_bloc.dart';
import '../../logic/blocs/transaction_bloc.dart';
import '../../logic/blocs/filter_bloc.dart';
import '../../logic/events/transaction_event.dart';
import '../../logic/events/filter_event.dart'; 
import '../../logic/states/category_state.dart';
import '../../logic/states/transaction_state.dart';
import '../../logic/states/filter_state.dart';
import '../widgets/transaction_list_item.dart';
import 'add_transaction_screen.dart';
import 'dashboard_view.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  //Funcao para mostrar o seletor de período
  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = context.read<FilterBloc>().state.dateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      //atualizo o FilterBloc
      context.read<FilterBloc>().add(UpdateDateRange(dateRange: newDateRange));
      //dispara o recarregamento
      context.read<TransactionBloc>().add(LoadTransactions(dateRange: newDateRange));
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard Financeiro'),
          centerTitle: true,
          actions: [
            
            
            BlocBuilder<FilterBloc, FilterState>(
              builder: (context, state) {
                return IconButton(
                  icon: Icon(
                    state.dateRange == null ? Icons.filter_list : Icons.filter_list_off,
                  ),
                  onPressed: () => _selectDateRange(context),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Transações'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Dashboard'),
            ],
          ),
        ),
        // tabarview para alternar entre as abas
        body: const TabBarView(
          children: [
            // Conteúdo da primeira aba
            TransactionListView(),
            // Conteúdo da segunda aba 
            DashboardView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}


class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        if (categoryState is CategoryLoaded) {
          final categoryMap = {for (var cat in categoryState.categories) cat.id: cat};

          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              if (transactionState is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (transactionState is TransactionLoaded) {
                if (transactionState.transactions.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma transação encontrada.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: transactionState.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactionState.transactions[index];
                    final category = categoryMap[transaction.categoryId];

                    return TransactionListItem(
                      transaction: transaction,
                      category: category,
                    );
                  },
                );
              }
              if (transactionState is TransactionError) {
                return Center(child: Text(transactionState.message));
              }
              return const Center(child: Text('Iniciando...'));
            },
          );
        }
        if (categoryState is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (categoryState is CategoryError) {
          return Center(child: Text(categoryState.message));
        }
        return const Center(child: Text('Carregando categorias...'));
      },
    );
  }
}