class Tools {
  static String handleAuthorsName(List<String> authors) {
    if (authors.isEmpty) {
      return 'Autor não disponível';
    } else if (authors.length == 1) {
      return authors.first;
    } else if (authors.length == 2) {
      return '${authors[0]} e ${authors[1]}';
    }
    return '${authors.first} e outros';
  }
}
