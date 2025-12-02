import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/models/categoria_model.dart';
import '../../data/models/transacao_model.dart';
import '../../logica/blocs/categoria_bloc.dart';
import '../../logica/blocs/transacao_bloc.dart';
import '../../logica/blocs/filter_bloc.dart';
import '../../logica/events/transacao_event.dart';
import '../../logica/events/filter_event.dart';
import '../../logica/states/categoria_state.dart';
import '../../logica/states/transacao_state.dart';
import '../../logica/states/filter_state.dart';
import '../widgets/item_lista_transacao.dart';
import 'add_transacao.dart';
import 'dashboard_view.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  Future<void> _selectDateRange(BuildContext context) async {
    // peega o estado atual do filterbloc para saber se existe um filtro aplicado
    final initialDateRange = context.read<FilterBloc>().state.dateRange ??
        //  define um intervalo padrao
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

   //seletor de data
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );

    //  o usuario selecionou um novo intervalo
    if (newDateRange != null) {
      
      context.read<FilterBloc>().add(UpdateDateRange(dateRange: newDateRange));
      // recarregar as transacoes com o novo filtro de data
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
            //ouve as mudanças no filterbloc
            BlocBuilder<FilterBloc, FilterState>(
              builder: (context, state) {
                // O ícone do botão muda dependendo se há um filtro de data ativo ou n
                return IconButton(
                  icon: Icon(
                    state.dateRange == null ? Icons.filter_list : Icons.filter_list_off,
                  ),
                  // funcao para selecionar o intervalo de datas
                  onPressed: () => _selectDateRange(context),
                );
              },
            ),
          ],
          // tabbar
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list_alt), text: 'Transações'),
              Tab(icon: Icon(Icons.pie_chart), text: 'Gráfico'),
            ],
          ),
        ),
        
        body: const TabBarView(
          children: [
            
            TransactionListView(),
          
            DashboardView(),
          ],
        ),
        // botao para adicionar uma nova transacao
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navega pra adicionar transacao
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

/// widget responsavel por exibir a lista de transacoes

class TransactionListView extends StatelessWidget {
  const TransactionListView({super.key});

  @override
  Widget build(BuildContext context) {
    //  Ouve bloc de categoria
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        // validacao
        if (categoryState is CategoryLoaded) {
          
          final categoryMap = {for (var cat in categoryState.categories) cat.id: cat};

          // ouve bloco de trnsacao
          return BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, transactionState) {
              // Se as transacoes estao carregando
              if (transactionState is TransactionLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              // Se as transacoes foram carregadas com sucesso
              if (transactionState is TransactionLoaded) {
               
                if (transactionState.transactions.isEmpty) {
                  return const Center(
                    child: Text('Nenhuma transação encontrada.'),
                  );
                }
                // Se houver transacoes, constroi a lista
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: transactionState.transactions.length,
                  itemBuilder: (context, index) {
                    // Pega a transacao e a categoria
                    final transaction = transactionState.transactions[index];
                    final category = categoryMap[transaction.categoryId];

                    // desenhar cada linha da lista
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
              // estado inicial
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