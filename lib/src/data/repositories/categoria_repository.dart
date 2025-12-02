import 'package:flutter/material.dart';
import '../datasources/local_datasource.dart';
import '../models/categoria_model.dart';

class CategoryRepository {
  final LocalDataSource localDataSource;

  CategoryRepository({required this.localDataSource});

  /// Busca todas as categorias
  Future<List<Category>> getAllCategories() async {
    var categories = await localDataSource.getAllCategories();
    
    if (categories.isEmpty) {
      await _insertDefaultCategories();
      categories = await localDataSource.getAllCategories();
    }
    return categories;
  }

  ///insere categorias padrão no banco de dados
  Future<void> _insertDefaultCategories() async {
    final defaultCategories = [
      Category(name: 'Alimentação', iconCodePoint: Icons.food_bank.codePoint, color: '#FF6347'),
      Category(name: 'Transporte', iconCodePoint: Icons.directions_car.codePoint, color: '#4169E1'),
      Category(name: 'Moradia', iconCodePoint: Icons.home.codePoint, color: '#3CB371'),
      Category(name: 'Lazer', iconCodePoint: Icons.sports_esports.codePoint, color: '#FFD700'),
      Category(name: 'Saúde', iconCodePoint: Icons.medical_services.codePoint, color: '#F08080'),
      Category(name: 'Receita', iconCodePoint: Icons.attach_money.codePoint, color: '#8FBC8F'),
    ];

    for (final category in defaultCategories) {
      await localDataSource.insertCategory(category);
    }
  }
}