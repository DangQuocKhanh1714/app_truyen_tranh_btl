import 'package:equatable/equatable.dart';
import '../../data/models/manga_model.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<MangaModel> mangas;
  CategoryLoaded(this.mangas);

  @override
  List<Object?> get props => [mangas];
}

class CategoryError extends CategoryState {
  final String message;
  CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}