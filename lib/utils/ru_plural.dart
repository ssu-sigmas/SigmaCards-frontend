/// Склонение для интерфейса (карточки, повторения).
String ruCardCountLabel(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) {
    return '$count карточек';
  }
  if (mod10 == 1) return '$count карточка';
  if (mod10 >= 2 && mod10 <= 4) return '$count карточки';
  return '$count карточек';
}

/// «1 день», «2 дня», «5 дней» — только слово с числом.
String ruDaysWord(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) return 'дней';
  if (mod10 == 1) return 'день';
  if (mod10 >= 2 && mod10 <= 4) return 'дня';
  return 'дней';
}

String ruDueCountLabel(int count) {
  if (count == 0) return 'нет к повторению';
  final mod10 = count % 10;
  final mod100 = count % 100;
  if (mod100 >= 11 && mod100 <= 14) {
    return '$count к повторению';
  }
  if (mod10 == 1) return '$count к повторению';
  return '$count к повторению';
}
