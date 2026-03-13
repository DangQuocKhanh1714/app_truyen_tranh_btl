import 'package:equatable/equatable.dart';

abstract class HistoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadHistoryEvent extends HistoryEvent {}

// Thêm class này để xử lý việc lưu lịch sử đọc
class AddHistoryEvent extends HistoryEvent {
  final int mangaId;
  final int chapterId;

  AddHistoryEvent({required this.mangaId, required this.chapterId});

  @override
  List<Object?> get props => [mangaId, chapterId];
}

// (Tùy chọn) Event để xóa lịch sử
class DeleteHistoryEvent extends HistoryEvent {
  final int mangaId;

  DeleteHistoryEvent({required this.mangaId});

  @override
  List<Object?> get props => [mangaId];
}
class RemoveHistoryItemEvent extends HistoryEvent {
  final int mangaId;
  RemoveHistoryItemEvent(this.mangaId);
}