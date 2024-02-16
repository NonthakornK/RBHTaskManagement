import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'src/app.dart';
import 'main.config.dart';

final getIt = GetIt.instance;
@InjectableInit(
  initializerName: 'init', // default
  preferRelativeImports: true, // default
  asExtension: true, // default
)
void configureDependencies() => getIt.init();
void main() async {
  getIt.registerSingleton(Dio());
  configureDependencies();
  runApp(const MyApp());
}
