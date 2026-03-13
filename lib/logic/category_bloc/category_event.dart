import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMangasByCategory extends CategoryEvent {
  final String categoryName;
  final String? query;

  FetchMangasByCategory(this.categoryName, {this.query});

  @override
  List<Object?> get props => [categoryName, query];
}