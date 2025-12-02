import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object?> get props => [];
}

/// evento pra atualizar o periodo do filtro
class UpdateDateRange extends FilterEvent {
  final DateTimeRange dateRange;

  const UpdateDateRange({required this.dateRange});

  @override
  List<Object?> get props => [dateRange];
}