import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@lazySingleton
class SessionManager {
  static const _durationTimeout = Duration(minutes: 10);
  static const _pinNumber = ['1', '2', '3', '4', '5', '6'];

  Timer? _timer;
  bool _isLoggedIn = false;

  final PublishSubject<Object?> _idleTimeOut = PublishSubject();
  Stream<Object?> get idleTimeOut => _idleTimeOut;

  @disposeMethod
  void dispose() {
    _timer?.cancel();
  }

  void startIdleTimer() {
    _timer?.cancel();
    if (_isLoggedIn) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_durationTimeout.inSeconds - timer.tick <= 0) {
          _isLoggedIn = false;
          timer.cancel();
          _idleTimeOut.add(null);
        }
      });
    }
  }

  bool onPinEntered(List<String> pin) {
    if (listEquals(pin, _pinNumber)) {
      _isLoggedIn = true;
      startIdleTimer();
      return true;
    }
    return false;
  }
}
