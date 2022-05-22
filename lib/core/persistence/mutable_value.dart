import 'persistence.dart';

class MutableValue<T> {
  final String key;
  MutableValue(this.key);

  T get val => Persistence.box.get(key);

  set val(T value) {
    Persistence.box.put(key, value);
    Persistence.to.update();
  }
}

extension Data<T> on T {
  MutableValue<T> val(String key) => MutableValue(key);
}
