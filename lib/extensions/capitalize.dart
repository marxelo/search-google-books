extension StringExtension on String {
  String capitalize() {
    return split(' ')
        .where((word) => word.isNotEmpty)
        .toList()
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .toList()
        .join(' ');
  }
}
