sealed class UiState<T> {
  const UiState();
}

class UiStateLoading<T> extends UiState<T> {
  const UiStateLoading();
}

class UiStateEmpty<T> extends UiState<T> {
  final String? message;
  const UiStateEmpty([this.message]);
}

class UiStateSuccess<T> extends UiState<T> {
  final T data;
  const UiStateSuccess(this.data);
}

class UiStateDegraded<T> extends UiState<T> {
  final T data;
  final String warningMessage;
  const UiStateDegraded(this.data, this.warningMessage);
}

class UiStateFailed<T> extends UiState<T> {
  final Object error;
  final StackTrace? stackTrace;
  final String? userMessage;
  const UiStateFailed(this.error, {this.stackTrace, this.userMessage});
}
