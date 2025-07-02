import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A generic Riverpod-based loader widget that can replace the RepositoryLoader pattern
class RiverpodLoader<T> extends ConsumerWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final Widget? loadingWidget;
  final Widget? noDataWidget;

  const RiverpodLoader({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.errorBuilder,
    this.loadingWidget,
    this.noDataWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncValue.when(
      data: (data) {
        if (data == null) {
          return noDataWidget ?? const Center(child: Text('No data'));
        }
        return builder(context, data);
      },
      loading: () =>
          loadingWidget ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          errorBuilder?.call(error, stackTrace) ??
          Center(child: Text('Error: $error')),
    );
  }
}
