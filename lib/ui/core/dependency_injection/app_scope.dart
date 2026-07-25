import 'package:flutter/widgets.dart';
import 'package:stars/ui/core/dependency_injection/app_dependencies.dart';

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.dependencies, required super.child});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'No AppScope found above this context.');
    return scope!;
  }

  static AppDependencies? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()?.dependencies;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
