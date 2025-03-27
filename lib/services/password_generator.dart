import 'dart:math';

String generatePassword() {
  const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  const lowerCase = "abcdefghijklmnopqrstuvwxyz";
  const nums = "0123456789";
  const symbols = "@!-_=+-/*.,:;[]{}()&^%#`~";
  
  final rand = Random();
  
  String password = '';
  password += upperCase[rand.nextInt(upperCase.length)];
  print(password);
  password += lowerCase[rand.nextInt(lowerCase.length)];
  print(password);
  password += nums[rand.nextInt(nums.length)];
  print(password);
  password += symbols[rand.nextInt(symbols.length)];
  print(password);
  
  const allChars = upperCase + lowerCase + nums + symbols;
  
  int remainingLength = 10 - 4;
  for (int i = 0; i < remainingLength; i++) {
    password += allChars[rand.nextInt(allChars.length)];
  }
  print(password);
  List<int> runes = password.runes.toList();
  runes.shuffle(rand);
  print(runes);
  return String.fromCharCodes(runes);
}
