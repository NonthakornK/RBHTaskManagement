import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rbh_task_management/src/data/response/task_list_response.dart';
import 'package:rbh_task_management/src/presentation/task_list/task_list_view_model.dart';
import 'package:rbh_task_management/src/repository/task_list_repository.dart';

class MockGetTaskList extends Mock implements TaskListRepository {}

void main() {
  late TaskListViewModel viewModel;
  final mockTaskListRepository = MockGetTaskList();

  final task1 = Task(
    id: "abc123",
    title: "task no.1",
    description: "description 1",
    createdAt: DateTime(2024, 1, 1),
    status: "",
  );

  final task2 = Task(
    id: "def456",
    title: "task no.2",
    description: "description 2",
    createdAt: DateTime(2024, 1, 2),
    status: "",
  );

  final todoResponse = TaskListResponse(
    tasks: [task1.copyWith(status: "TODO")],
    pageNumber: 1,
    totalPages: 2,
  );
  final todoResponse2 = TaskListResponse(
    tasks: [task2.copyWith(status: "TODO")],
    pageNumber: 2,
    totalPages: 2,
  );

  final doingResponse = TaskListResponse(
    tasks: [task1.copyWith(status: "DOING")],
    pageNumber: 1,
    totalPages: 2,
  );
  final doingResponse2 = TaskListResponse(
    tasks: [task2.copyWith(status: "DOING")],
    pageNumber: 2,
    totalPages: 2,
  );

  final doneResponse = TaskListResponse(
    tasks: [task1.copyWith(status: "DONE")],
    pageNumber: 1,
    totalPages: 2,
  );
  final doneResponse2 = TaskListResponse(
    tasks: [task2.copyWith(status: "DONE")],
    pageNumber: 2,
    totalPages: 2,
  );

  setUpAll(() {
    viewModel = TaskListViewModel(mockTaskListRepository);
  });

  group('TaskListViewModel test', () {
    // Run sequentually
    test('on page load', () async {
      when(
        () => mockTaskListRepository.getTaskList("TODO", 0),
      ).thenAnswer(
        (_) async => todoResponse,
      );
      when(
        () => mockTaskListRepository.getTaskList("DOING", 0),
      ).thenAnswer(
        (_) async => doingResponse,
      );
      when(
        () => mockTaskListRepository.getTaskList("DONE", 0),
      ).thenAnswer(
        (_) async => doneResponse,
      );

      viewModel.onPageLoad();

      await Future.wait([
        expectLater(viewModel.todoList, emits(todoResponse)),
        expectLater(viewModel.doingList, emits(doingResponse)),
        expectLater(viewModel.doneList, emits(doneResponse)),
      ]);
    });

    group('on scroll end', () {
      test('TODO', () async {
        when(
          () => mockTaskListRepository.getTaskList("TODO", 1),
        ).thenAnswer((_) async => todoResponse2);

        await viewModel.onScrollEnd(TaskGroup.todo);

        await expectLater(
          viewModel.todoList,
          emits(todoResponse2.copyWith(tasks: [
            task1.copyWith(status: "TODO"),
            task2.copyWith(status: "TODO"),
          ])),
        );
      });

      test('DOING', () async {
        when(
          () => mockTaskListRepository.getTaskList("DOING", 1),
        ).thenAnswer((_) async => doingResponse2);

        await viewModel.onScrollEnd(TaskGroup.doing);

        await expectLater(
          viewModel.doingList,
          emitsAnyOf([
            doingResponse2.copyWith(tasks: [
              task1.copyWith(status: "DOING"),
              task2.copyWith(status: "DOING"),
            ])
          ]),
        );
      });

      test('DONE', () async {
        when(
          () => mockTaskListRepository.getTaskList("DONE", 1),
        ).thenAnswer((_) async => doneResponse2);

        await viewModel.onScrollEnd(TaskGroup.done);

        await expectLater(
          viewModel.doneList,
          emitsAnyOf([
            doneResponse2.copyWith(tasks: [
              task1.copyWith(status: "DONE"),
              task2.copyWith(status: "DONE"),
            ])
          ]),
        );
      });
    });

    group('on task dismiss', () {
      test('TODO', () async {
        viewModel.onDismiss(0, "abc123");

        await expectLater(viewModel.todoList, emits(todoResponse2));
      });

      test('DOING', () async {
        viewModel.onDismiss(1, "abc123");

        await expectLater(viewModel.doingList, emits(doingResponse2));
      });

      test('DONE', () async {
        viewModel.onDismiss(2, "abc123");

        await expectLater(viewModel.doneList, emits(doneResponse2));
      });
    });
  });
}
