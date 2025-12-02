import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/filter_event.dart';
import '../states/filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc() : super(const FilterState()) {
    on<UpdateDateRange>(_onUpdateDateRange);
  }

  void _onUpdateDateRange(UpdateDateRange event, Emitter<FilterState> emit) {
    emit(state.copyWith(dateRange: event.dateRange));
  }
}