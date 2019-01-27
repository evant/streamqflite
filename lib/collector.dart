/// Interface for collecting elements of type [T] into a value of type [R].
abstract class Collector<T, A, R> {
  /// Supplies an accumulator to accumulate elements into.
  A supply(int length);

  /// Adds an [element] into the [accumulator] at [index]. This will always be
  /// appended, the index is provided for convenience.
  void add(A accumulator, int index, T element);

  /// Constructs result of type [R] from the [accumulator].
  R finish(A accumulator);
}

/// Collects elements into a [List]
class ListCollector<T> implements Collector<T, List<T>, List<T>> {
  const ListCollector();

  @override
  List<T> supply(int length) => List(length);

  @override
  void add(List<T> acc, int index, T elem) {
    acc[index] = elem;
  }

  @override
  List<T> finish(List<T> acc) => List.unmodifiable(acc);
}
