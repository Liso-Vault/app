import 'persistence.dart';

class MutableValue<T> {
  final String key;
  final T defaultValue;

  MutableValue(this.key, this.defaultValue);

  T get val => Persistence.box != null && Persistence.box!.isOpen
      ? Persistence.box?.get(key) ?? defaultValue
      : defaultValue;

  set val(T value) {
    if (Persistence.box == null || !Persistence.box!.isOpen) return;
    Persistence.box?.put(key, value);
    Persistence.to.update();
  }
}

extension Data<T> on T {
  MutableValue<T> val(
    String key, {
    T? defaultValue,
  }) =>
      MutableValue(key, defaultValue ?? this);
}
