class AppFailure implements Exception {
  const AppFailure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code == null ? message : '$code: $message';
}

sealed class AppResult<T> {
  const AppResult();

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) {
    final result = this;
    return switch (result) {
      AppSuccess<T>(:final value) => success(value),
      AppError<T>(:final error) => failure(error),
    };
  }
}

class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.value);

  final T value;
}

class AppError<T> extends AppResult<T> {
  const AppError(this.error);

  final AppFailure error;
}
