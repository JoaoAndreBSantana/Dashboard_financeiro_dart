import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class FilterState extends Equatable {
  //O periodo do filtro
  final DateTimeRange? dateRange;

  const FilterState({this.dateRange});

  
  FilterState copyWith({DateTimeRange? dateRange}) {
    return FilterState(
      dateRange: dateRange ?? this.dateRange,
    );
  }

  @override
  List<Object?> get props => [dateRange];
}