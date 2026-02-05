extension ListExtensions<T> on List<T> {
  bool get isNotEmptyList => isNotEmpty;
  bool get isEmptyList => isEmpty;
  List<T> get reversedList => reversed.toList();
}

extension MapExtensions<K,V> on Map<K,V> {
  bool get hasData => isNotEmpty;
  List<K> get keysList => keys.toList();
  List<V> get valuesList => values.toList();
}
