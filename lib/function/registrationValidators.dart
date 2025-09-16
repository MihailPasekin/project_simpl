class Validators {
  /// Проверка имени
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Введите имя";
    }
    if (value.trim().length < 2) {
      return "Имя слишком короткое";
    }
    if (!RegExp(r'^[a-zA-Zа-яА-ЯёЁ\s]+$').hasMatch(value.trim())) {
      return "Имя может содержать только буквы";
    }
    return null; // Всё ок ✅
  }

  /// Проверка email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Введите email";
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return "Введите корректный email";
    }
    return null;
  }

  /// Проверка пароля
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Введите пароль";
    }
    if (value.length < 6) {
      return "Пароль должен быть не менее 6 символов";
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return "Пароль должен содержать хотя бы одну заглавную букву";
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Пароль должен содержать хотя бы одну цифру";
    }
    return null;
  }
}
