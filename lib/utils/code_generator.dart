import 'dart:math';

String generateRandomCode() {
  final random = Random();
  String code = '';
  for (int i = 0; i < 4; i++) {
    code += random.nextInt(10).toString();
  }
  return code;
}
