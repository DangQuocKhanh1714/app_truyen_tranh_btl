import 'package:equatable/equatable.dart';

abstract class MangaEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Sự kiện tải toàn bộ danh sách truyện
class LoadMangaEvent extends MangaEvent {}

// Sự kiện tìm kiếm truyện
class SearchManga extends MangaEvent {
  final String query;
  SearchManga(this.query);

  @override
  List<Object?> get props => [query];
}