import 'dart:math';

String generatePassword() {
  const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const lowerCase = "abcdefghijklmnopqrstuvwxyz";
  const nums = "0123456789";
  const symbols = "@!-_=+-/*.,:;[]{}()&^%#`~";

  String pw = '';

  final rand = Random();

  const allChars = upperCase + lowerCase + nums + symbols;

  for(int i = 0; i < 10; i++) {
    pw += allChars[rand.nextInt(allChars.length)]; 
  }

  return String.fromCharCodes(pw.runes.toList()..shuffle(rand));
}