/// Result class for handling success and error states in a unified way.
///
/// This class is used to wrap the result of operations that can either succeed or fail,
/// providing a consistent way to handle both cases.
class Result<T> {
  final T? data;
  final String? errorMessage;
  final ResultStatus status;

  /// Creates a success result with the provided [data].
  Result.success(this.data)
    : status = ResultStatus.success,
      errorMessage = null;

  /// Creates an error result with the provided [errorMessage] and optional [status].
  Result.error(this.errorMessage, [this.status = ResultStatus.error])
    : data = null;

  /// Creates a network error result with a default error message.
  Result.networkError()
    : status = ResultStatus.networkError,
      data = null,
      errorMessage = "ネットワークエラーが発生しました。接続を確認してください。";

  /// Creates a not found error result with a default error message.
  Result.notFound([String? message])
    : status = ResultStatus.notFound,
      data = null,
      errorMessage = message ?? "リソースが見つかりませんでした。";

  /// Creates an unauthorized error result with a default error message.
  Result.unauthorized([String? message])
    : status = ResultStatus.unauthorized,
      data = null,
      errorMessage = message ?? "認証エラーが発生しました。再度ログインしてください。";

  /// Creates a validation error result with a default error message.
  Result.validationError([String? message])
    : status = ResultStatus.validationError,
      data = null,
      errorMessage = message ?? "入力データが無効です。";

  /// Returns true if the result is a success.
  bool get isSuccess => status == ResultStatus.success;

  /// Returns true if the result is an error.
  bool get isError => status != ResultStatus.success;

  /// Returns the data or throws an exception if the result is an error.
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(errorMessage ?? "Unknown error");
  }
}

/// Enum representing the status of a result.
enum ResultStatus {
  /// The operation was successful.
  success,

  /// A general error occurred.
  error,

  /// A network error occurred.
  networkError,

  /// The requested resource was not found.
  notFound,

  /// The user is not authorized to perform the operation.
  unauthorized,

  /// The input data is invalid.
  validationError,
}
