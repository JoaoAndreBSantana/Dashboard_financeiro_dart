import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';



class Category extends Equatable {
  final int? id; 
  final String name; 
  final int iconCodePoint; 
  final String color; 

  const Category({
    this.id,
    required this.name,
    required this.iconCodePoint,
    required this.color,
  });

  
  @override
  List<Object?> get props => [id, name, iconCodePoint, color];

  // converte um objeto category em um mapa 
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': iconCodePoint,
      'color': color,
    };
  }

  //cria um objeto 
  
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