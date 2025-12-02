import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/transacao_repository.dart';
import '../events/transacao_event.dart';
import '../states/transacao_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository,
        super(TransactionInitial()) {
    
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  //carrega as transacoes do repositorio
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository.getAllTransactions(
        dateRange: event.dateRange,
      );
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError("Falha ao carregar transações: ${e.toString()}"));
    }
  }

  //adiciona uma nova transacao 
  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _transactionRepository.addTransaction(event.transaction);
      
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError("Falha ao adicionar transação: ${e.toString()}"));
    }
  }

  
  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _transactionRepository.deleteTransaction(event.transactionId);
      
      add(LoadTransactions());
    } catch (e) {
      emit(TransactionError("Falha ao deletar transação: ${e.toString()}"));
    }
  }
}