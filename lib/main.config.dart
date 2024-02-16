// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i5;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

import 'src/core/session_manager.dart' as _i3;
import 'src/presentation/task_list/task_list_view_model.dart' as _i7;
import 'src/repository/task_list_repository.dart' as _i6;
import 'src/service/task_list_service.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.lazySingleton<_i3.SessionManager>(
      () => _i3.SessionManager(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i4.TaskListService>(_i4.TaskListService(gh<_i5.Dio>()));
    gh.singleton<_i6.TaskListRepository>(
        _i6.TaskListRepositoryImpl(gh<_i4.TaskListService>()));
    gh.factory<_i7.TaskListViewModel>(
        () => _i7.TaskListViewModel(gh<_i6.TaskListRepository>()));
    return this;
  }
}
