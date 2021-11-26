import 'dart:math';

class Utils {
  // TODO: improve password validation
  static String validatePassword(String text) {
    const min = 8;
    const max = 30;

    if (text.isEmpty) {
      return 'Enter your strong password';
    } else if (text.length < min) {
      return 'Vault password must be at least $min characters';
    } else if (text.length > max) {
      return "That's a lot of a password";
    } else {
      return '';
    }
  }

  static String generatePassword({
    bool letter = true,
    bool isNumber = true,
    bool isSpecial = true,
    int length = 15,
  }) {
    const letterLowerCase = "abcdefghijklmnopqrstuvwxyz";
    const letterUpperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const number = '0123456789';
    const special = '@#%^*>\$@?/[]=+';

    String chars = "";
    if (letter) chars += ' $letterLowerCase $letterUpperCase ';
    if (isNumber) chars += ' $number ';
    if (isSpecial) chars += ' $special ';

    return List.generate(length, (index) {
      final indexRandom = Random.secure().nextInt(chars.length);
      return chars[indexRandom];
    }).join('');
  }
}
