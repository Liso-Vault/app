import '../../main.dart';
import 'flavors.dart';

void main() => init(Flavor.debug);

void autofillEntryPoint() => init(Flavor.debug, autofill: true);
