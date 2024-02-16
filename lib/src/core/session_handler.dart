import 'package:flutter/material.dart';
import 'package:rbh_task_management/main.dart';
import 'package:rbh_task_management/src/core/session_manager.dart';
import 'package:rbh_task_management/src/presentation/pin_verify/pin_verify_page.dart';

mixin SessionHandler<T extends StatefulWidget> on State<T> {
  final SessionManager _sessionManager = getIt<SessionManager>();

  @override
  void initState() {
    super.initState();

    _sessionManager.idleTimeOut.listen((_) {
      if(!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        PinVerifyPage.routeName,
        (route) => false,
      );
    });
  }
}
