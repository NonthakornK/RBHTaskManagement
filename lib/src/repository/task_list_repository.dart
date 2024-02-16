import 'package:injectable/injectable.dart';
import 'package:rbh_task_management/src/data/response/task_list_response.dart';

import '../service/task_list_service.dart';

abstract class TaskListRepository {
  Future<TaskListResponse> getTaskList(String status, int offset);
}

@Singleton(as: TaskListRepository)
class TaskListRepositoryImpl extends TaskListRepository {
  final TaskListService _service;

  TaskListRepositoryImpl(this._service);

  @override
  Future<TaskListResponse> getTaskList(String status, int offset) async {
    final response = await _service
        .getTaskList(offset, 10, "createdAt", true, status)
        .catchError((obj) => null);
    if (response != null) return response;

    throw Exception();
  }
}
