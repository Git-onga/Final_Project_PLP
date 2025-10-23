class Helpers {
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}