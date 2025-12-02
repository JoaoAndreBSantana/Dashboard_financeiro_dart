import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/categoria_repository.dart';
import '../events/categoria_event.dart';
import '../states/categoria_state.dart';


class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

 
  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    // registra o handler para o evento loadcategorias
    on<LoadCategories>(_onLoadCategories);
  }

 
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
   
    emit(CategoryLoading());
    try {
      
      final categories = await _categoryRepository.getAllCategories();
      
      emit(CategoryLoaded(categories));
    } catch (e) {
      
      emit(CategoryError("Falha ao carregar categorias: ${e.toString()}"));
    }
  }
}