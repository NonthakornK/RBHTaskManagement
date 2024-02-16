import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../data/response/task_list_response.dart';

part 'task_list_service.g.dart';

@singleton
@RestApi(baseUrl: 'https://todo-list-api-mfchjooefq-as.a.run.app')
abstract class TaskListService {
  @factoryMethod
  factory TaskListService(Dio dio) => _TaskListService(dio);

  @GET('/todo-list')
  Future<TaskListResponse?> getTaskList(
    @Query("offset") int? offset,
    @Query("limit") int? limit,
    @Query("sortBy") String? sortBy,
    @Query("isAsc") bool? isAsc,
    @Query("status") String? status,
  );
}
