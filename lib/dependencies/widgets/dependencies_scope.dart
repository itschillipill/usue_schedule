import 'package:flutter/material.dart';

import '../dependencies.dart';

class DependenciesScope extends StatelessWidget {
  const DependenciesScope({
    required this.initialization,
    required this.splashScreen,
    this.errorBuilder,
    required this.child,
    super.key,
  });

  final Future<Dependencies> initialization;
  final Widget splashScreen;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final Widget child;

  static Dependencies? maybeOf(BuildContext context) => switch (context
          .getElementForInheritedWidgetOfExactType<_InheritedDependencies>()
          ?.widget) {
        _InheritedDependencies inheritedDependencies =>
          inheritedDependencies.dependencies,
        _ => null,
      };

  static Never _notFoundInheritedWidgetOfExactType() {
    throw ArgumentError(
      'Out of scope, not found inherited widget '
          'a DependenciesScope of the exact type',
      'out_of_scope',
    );
  }

  static Dependencies of(BuildContext context) =>
      maybeOf(context) ?? _notFoundInheritedWidgetOfExactType();

  @override
  Widget build(BuildContext context) => FutureBuilder(
      future: initialization,
      builder: (context, asyncSnapshot) => switch ((
            asyncSnapshot.data,
            asyncSnapshot.error,
            asyncSnapshot.stackTrace
          )) {
            (Dependencies dependencies, null, null) => _InheritedDependencies(
                dependencies: dependencies,
                child: child,
              ),
            (_, Object error, StackTrace? stackTrace) =>
              errorBuilder?.call(error, stackTrace) ?? ErrorWidget(error),
            _ => splashScreen,
          });
}

class _InheritedDependencies extends InheritedWidget {
  final Dependencies dependencies;
  const _InheritedDependencies(
      {required super.child, required this.dependencies});

  @override
  bool updateShouldNotify(covariant _InheritedDependencies oldWidget) => false;
}
