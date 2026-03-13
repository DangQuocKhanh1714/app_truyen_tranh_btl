import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnQueryChanged extends SearchEvent {
  final String query;
  OnQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends SearchEvent {}