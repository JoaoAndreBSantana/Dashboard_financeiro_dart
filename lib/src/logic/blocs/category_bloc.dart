import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/category_repository.dart';
import '../events/category_event.dart';
import '../states/category_state.dart';


class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

 
  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    // registra o handler para o evento loadcategorias
    on<LoadCategories>(_onLoadCategories);
  }

  //método chamado quando o evento loadcategories é adicionado ao bloc
  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
   
    emit(CategoryLoading());
    try {
      // Tenta buscar as categorias do repositório.
      final categories = await _categoryRepository.getAllCategories();
      
      emit(CategoryLoaded(categories));
    } catch (e) {
      
      emit(CategoryError("Falha ao carregar categorias: ${e.toString()}"));
    }
  }
}