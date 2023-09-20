import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class IndexControllerEventBase {
  IndexControllerEventBase({required this.animation, this.duration});

  final bool animation;
  final Duration? duration;

  final completer = Completer<void>();

  Future<void> get future => completer.future;

  void complete() {
    if (!completer.isCompleted) {
      completer.complete();
    }
  }
}

mixin TargetedPositionControllerEvent on IndexControllerEventBase {
  double get targetPosition;
}
mixin StepBasedIndexControllerEvent on TargetedPositionControllerEvent {
  int get step;

  int calcNextIndex({
    required int currentIndex,
    required int itemCount,
    required bool loop,
    required bool reverse,
  }) {
    var cIndex = currentIndex;
    if (reverse) {
      cIndex -= step;
    } else {
      cIndex += step;
    }

    if (!loop) {
      if (cIndex >= itemCount) {
        cIndex = itemCount - 1;
      } else if (cIndex < 0) {
        cIndex = 0;
      }
    }
    return cIndex;
  }
}

class NextIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent, StepBasedIndexControllerEvent {
  NextIndexControllerEvent({
    required bool animation,
    required Duration duration,
  }) : super(
          animation: animation,
          duration: duration,
        );

  @override
  int get step => 1;

  @override
  double get targetPosition => 0;
}

class PrevIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent, StepBasedIndexControllerEvent {
  PrevIndexControllerEvent({
    required bool animation,
  }) : super(
          animation: animation,
        );

  @override
  int get step => -1;

  @override
  double get targetPosition => 1;
}

class MoveIndexControllerEvent extends IndexControllerEventBase
    with TargetedPositionControllerEvent {
  MoveIndexControllerEvent({
    required this.newIndex,
    required this.oldIndex,
    required bool animation,
    required Duration duration,
  }) : super(
          animation: animation,
          duration: duration,
        );
  final int newIndex;
  final int oldIndex;

  @override
  double get targetPosition => newIndex > oldIndex ? 1 : 0;
}

class IndexController extends ChangeNotifier {
  IndexControllerEventBase? event;
  int index = 0;

  Future<void> move(int index,
      {bool animation = true, Duration duration = const Duration(seconds: 3)}) {
    final e = event = MoveIndexControllerEvent(
        animation: animation,
        newIndex: index,
        oldIndex: this.index,
        duration: duration);
    notifyListeners();
    return e.future;
  }

  Future<void> next({
    bool animation = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    final e = event =
        NextIndexControllerEvent(animation: animation, duration: duration);
    notifyListeners();
    return e.future;
  }

  Future<void> previous({bool animation = true}) {
    final e = event = PrevIndexControllerEvent(animation: animation);
    notifyListeners();
    return e.future;
  }
}
