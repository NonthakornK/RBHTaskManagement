import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_list_response.freezed.dart';
part 'task_list_response.g.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class TaskListResponse with _$TaskListResponse {
  const factory TaskListResponse({
    List<Task>? tasks,
    int? pageNumber,
    int? totalPages,
  }) = _TaskListResponse;

  factory TaskListResponse.fromJson(Map<String, Object?> json)
      => _$TaskListResponseFromJson(json);
}

@freezed
class Task with _$Task {
  const factory Task({
    required String id,
    required String title,
    required String description,
    required DateTime createdAt,
    required String status,
  }) = _Task;

  factory Task.fromJson(Map<String, Object?> json)
      => _$TaskFromJson(json);
}