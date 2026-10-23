import 'package:flutter/foundation.dart';

/// Explicit state model for every data-loading screen (MVVM requirement)
sealed class ViewState<T> {
  const ViewState();
}

class InitialState<T> extends ViewState<T> {
  const InitialState();
}

class LoadingState<T> extends ViewState<T> {
  final String? message;
  const LoadingState([this.message]);
}

class EmptyState<T> extends ViewState<T> {
  final String message;
  const EmptyState(this.message);
}

class ErrorState<T> extends ViewState<T> {
  final String message;
  final VoidCallback? onRetry;
  const ErrorState(this.message, {this.onRetry});
}

class SuccessState<T> extends ViewState<T> {
  final T data;
  const SuccessState(this.data);
}
