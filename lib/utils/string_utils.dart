extension StringNormalization on String {
  /// Normalizes a string by converting it to lowercase and removing all
  /// spaces, punctuation, and special characters. 
  /// Useful for matching OCR text with database records.
  String normalizeForSearch() {
    return toLowerCase().replaceAll(RegExp(r'[\s\W_]+'), '');
  }
}
