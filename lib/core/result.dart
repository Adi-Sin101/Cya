/// Explicit error handling for operations that can fail (PRD §9.4 — no silent
/// catches, no exceptions escaping into the widget tree).
///
/// Streams stay plain: Riverpod's `AsyncValue` already models their errors.
/// [Result] is for the *commands* the UI issues — capture, resolve, snooze.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppError error) = Failure<T>;

  bool get isSuccess => this is Success<T>;

  /// The value, or `null` when this is a failure.
  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppError? get errorOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final error) => error,
  };

  R fold<R>(R Function(T value) onSuccess, R Function(AppError error) onError) {
    return switch (this) {
      Success<T>(:final value) => onSuccess(value),
      Failure<T>(:final error) => onError(error),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);

  final AppError error;
}

/// Everything that can go wrong in a way the user should hear about.
sealed class AppError {
  const AppError();

  /// Message safe to show in the UI.
  String get message;
}

/// The local store rejected or could not complete a write.
final class StorageError extends AppError {
  const StorageError(this.cause, [this.stackTrace]);

  final Object cause;
  final StackTrace? stackTrace;

  @override
  String get message => "Couldn't save that. Your promise is still here.";
}

/// The promise no longer exists (deleted on another surface, for instance).
final class NotFoundError extends AppError {
  const NotFoundError(this.id);

  final int id;

  @override
  String get message => 'That promise is no longer here.';
}

/// The user has pushed this promise back as often as the product allows
/// (PRD §5.6 snooze limit). Not a bug — a deliberate nudge to close the loop.
final class SnoozeLimitError extends AppError {
  const SnoozeLimitError(this.snoozeCount, this.limit);

  final int snoozeCount;
  final int limit;

  @override
  String get message =>
      "You've pushed this back $snoozeCount times. Finish it, reschedule it "
      'properly, or let it go.';
}

/// Input the domain refuses (e.g. an empty capture).
final class ValidationError extends AppError {
  const ValidationError(this.message);

  @override
  final String message;
}
