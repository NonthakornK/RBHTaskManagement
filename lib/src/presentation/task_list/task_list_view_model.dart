import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rbh_task_management/src/data/response/task_list_response.dart';
import 'package:rbh_task_management/src/repository/task_list_repository.dart';
import 'package:rxdart/rxdart.dart';

enum TaskGroup { todo, doing, done }

@injectable
class TaskListViewModel extends ChangeNotifier {
  final TaskListRepository _taskListRepository;

  TaskListViewModel(this._taskListRepository);

  final BehaviorSubject<TaskListResponse> _todoList = BehaviorSubject();
  Stream<TaskListResponse> get todoList => _todoList;

  final BehaviorSubject<TaskListResponse> _doingList = BehaviorSubject();
  Stream<TaskListResponse> get doingList => _doingList;

  final BehaviorSubject<TaskListResponse> _doneList = BehaviorSubject();
  Stream<TaskListResponse> get doneList => _doneList;

  final PublishSubject<Object?> _isError = PublishSubject();
  Stream<Object?> get isError => _isError;

  void onPageLoad() {
    Future.wait([
      _getTaskList(TaskGroup.todo, 0),
      _getTaskList(TaskGroup.doing, 0),
      _getTaskList(TaskGroup.done, 0),
    ]);
  }

  Future<bool> _getTaskList(TaskGroup group, int offset) async {
    try {
      final response =
          await _taskListRepository.getTaskList(_getString(group), offset);
      if (offset == 0) {
        _getSubject(group).add(response);
      } else {
        final newTaskList = _getSubject(group).value.tasks;
        newTaskList?.addAll(response.tasks ?? []);
        _getSubject(group).add(
          response.copyWith(tasks: newTaskList),
        );
      }
      return true;
    } on Exception {
      _isError.add(null);
      _getSubject(group).add(
        const TaskListResponse(
          tasks: null,
          pageNumber: null,
          totalPages: null,
        ),
      );
      return false;
    }
  }

  void onDismiss(int index, String id) {
    final taskList = _getSubject(_getGroupFromIndex(index));
    final newTaskList = taskList.value;
    newTaskList.tasks?.removeWhere((element) => element.id == id);
    taskList.add(newTaskList);
  }

  Future<bool> onScrollEnd(TaskGroup group) {
    return _getTaskList(group, _getSubject(group).valueOrNull?.pageNumber ?? 0);
  }

  BehaviorSubject<TaskListResponse> _getSubject(TaskGroup group) {
    switch (group) {
      case TaskGroup.todo:
        return _todoList;
      case TaskGroup.doing:
        return _doingList;
      case TaskGroup.done:
        return _doneList;
    }
  }

  String _getString(TaskGroup group) {
    switch (group) {
      case TaskGroup.todo:
        return "TODO";
      case TaskGroup.doing:
        return "DOING";
      case TaskGroup.done:
        return "DONE";
    }
  }

  TaskGroup _getGroupFromIndex(int index) {
    switch (index) {
      case 0:
        return TaskGroup.todo;
      case 1:
        return TaskGroup.doing;
      case 2:
        return TaskGroup.done;
      default:
        throw Exception();
    }
  }
}
