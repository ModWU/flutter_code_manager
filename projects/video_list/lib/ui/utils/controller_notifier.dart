import 'dart:async';
import 'package:flutter/cupertino.dart';

class IndexController extends ChangeNotifier {
  static const int NEXT = 1;
  static const int PREVIOUS = -1;
  static const int MOVE = 0;

  Completer _completer;

  int _index;
  bool _animation;
  int _event;

  int get index => _index;
  bool get animation => _animation;
  int get event => _event;

  Future move(int index, {bool animation: true}) {
    _animation = animation ?? true;
    _index = index;
    _event = MOVE;
    _completer = new Completer();
    notifyListeners();
    return _completer.future;
  }

  Future next({bool animation: true}) {
    _event = NEXT;
    _animation = animation ?? true;
    _completer = new Completer();
    notifyListeners();
    return _completer.future;
  }

  Future previous({bool animation: true}) {
    _event = PREVIOUS;
    _animation = animation ?? true;
    _completer = new Completer();
    notifyListeners();
    return _completer.future;
  }

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}