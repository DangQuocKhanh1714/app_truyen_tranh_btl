import 'package:equatable/equatable.dart';
import '../../data/models/manga_model.dart';

abstract class MangaState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MangaInitial extends MangaState {}

class MangaLoading extends MangaState {}

class MangaLoaded extends MangaState {
  final List<MangaModel> mangas;
  MangaLoaded(this.mangas);

  @override
  List<Object?> get props => [mangas];
}

class MangaError extends MangaState {
  final String message;
  MangaError(this.message);

  @override
  List<Object?> get props => [message];
}