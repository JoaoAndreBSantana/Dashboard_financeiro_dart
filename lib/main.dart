import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/data/datasources/local_datasource.dart';
import 'src/data/repositories/categoria_repository.dart';
import 'src/data/repositories/transacao_repository.dart';
import 'src/logica/blocs/categoria_bloc.dart';
import 'src/logica/blocs/transacao_bloc.dart';
import 'src/logica/events/categoria_event.dart';
import 'src/logica/events/transacao_event.dart';
import 'src/apresentacao/screens/home_screen.dart';
import 'src/logica/blocs/filter_bloc.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const FinancialDashboardApp());
}

class FinancialDashboardApp extends StatelessWidget {
  const FinancialDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalDataSource>(
          create: (context) => LocalDataSource(),// instancia o datasource
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(
            localDataSource: RepositoryProvider.of<LocalDataSource>(context),
          ),
        ),
        RepositoryProvider<TransactionRepository>(
          create: (context) => TransactionRepository(
            localDataSource: RepositoryProvider.of<LocalDataSource>(context),
          ),
        ),
      ],
      
      // disponibiliza os bloc 
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FilterBloc>(
            create: (context) => FilterBloc(),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
            )..add(LoadCategories()), 
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => TransactionBloc(
              transactionRepository: RepositoryProvider.of<TransactionRepository>(context),
            )..add(LoadTransactions()),
          ),
        ],
        child: MaterialApp(
          title: 'Dashboard Financeiro',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            // Estilo para os cards
            cardTheme: const CardThemeData(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}