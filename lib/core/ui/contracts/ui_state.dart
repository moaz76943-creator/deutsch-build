import '../../architecture/operation_result.dart';

enum UIStateType { loading, empty, data, degraded, failed, corrupted }

class UIState<T> {
  final UIStateType type;
  final T? data;
  final OperationFailure? failure;
  final Object? rawError;
  final String? message;

  const UIState._({
    required this.type,
    this.data,
    this.failure,
    this.rawError,
    this.message,
  });

  factory UIState.loading() => const UIState._(type: UIStateType.loading);

  factory UIState.empty([String? message]) =>
      UIState._(type: UIStateType.empty, message: message);

  factory UIState.data(T data) =>
      UIState._(type: UIStateType.data, data: data);

  factory UIState.degraded(T data, {String? message, OperationFailure? failure}) =>
      UIState._(type: UIStateType.degraded, data: data, message: message, failure: failure);

  factory UIState.failed(OperationFailure failure, [String? message]) =>
      UIState._(type: UIStateType.failed, failure: failure, message: message);

  factory UIState.corrupted(Object error, [String? message]) =>
      UIState._(type: UIStateType.corrupted, rawError: error, message: message);

  bool get isLoading => type == UIStateType.loading;
  bool get isEmpty => type == UIStateType.empty;
  bool get hasData => type == UIStateType.data || type == UIStateType.degraded;
  bool get isFailed => type == UIStateType.failed || type == UIStateType.corrupted;
}
