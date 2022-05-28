class Flavors {
  static Flavor? flavor;

  static bool get isDebug => flavor == Flavor.debug;
  static bool get isRelease => flavor == Flavor.release;
}

enum Flavor { debug, release }
