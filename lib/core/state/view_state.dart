import '../errors/failure.dart';

/// The five states every data-driven screen moves through.
sealed class ViewState<T> {
  const ViewState();

  bool get isLoading => this is LoadingState<T>;
  T? get dataOrNull => switch (this) {
        SuccessState<T>(:final data) => data,
        _ => null,
      };
}

final class InitialState<T> extends ViewState<T> {
  const InitialState();
}

final class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}

final class SuccessState<T> extends ViewState<T> {
  const SuccessState(this.data);
  final T data;
}

final class EmptyState<T> extends ViewState<T> {
  const EmptyState();
}

final class ErrorState<T> extends ViewState<T> {
  const ErrorState(this.failure);
  final Failure failure;
}

/// Picks Success or Empty for list results.
ViewState<List<E>> listState<E>(List<E> items) =>
    items.isEmpty ? EmptyState<List<E>>() : SuccessState<List<E>>(items);
