import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Representa uma categoria de transação.

class Category extends Equatable {
  final int? id; 
  final String name; 
  final int iconCodePoint; // O código do ícone a ser exibido
  final String color; 

  const Category({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
  });

  /// Propriedades usadas pelo `Equatable` para comparar instâncias de Category.
  @override
  List<Object?> get props => [id, name, iconCodePoint, color];

  /// Converte um objeto Category em um mapa para facilitar o armazenamento no banco
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'color': color,
    };
  }

  ///cria um objeto Category a partir de um Map.
  
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      iconCodePoint: map['iconCodePoint'],
      color: map['color'],
    );
  }

  /// get para converter a string de cor hexadecimal em um objeto color
  Color get colorValue {
    final buffer = StringBuffer();
    if (color.length == 6 || color.length == 7) buffer.write('ff');
    buffer.write(color.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}