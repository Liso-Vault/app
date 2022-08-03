import '../../main.dart';
import 'flavors.dart';

void main() => init(Flavor.release);

@pragma('vm:entry-point')
void autofillEntryPoint() => init(Flavor.release, autofill: true);
