enum Filter {
  full(apiValor: 'full', dropDownValor: 'gratis'),
  freeEbooks(apiValor: 'free-ebooks', dropDownValor: 'free-ebooks'),
  ebooks(apiValor: 'e-books', dropDownValor: 'e-books'),
  paidEbooks(apiValor: 'paid-ebooks', dropDownValor: 'paid-e-books'),
  partial(apiValor: 'partial', dropDownValor: 'partial'),
  all(apiValor: 'all', dropDownValor: 'tudo');

  const Filter({
    required this.apiValor,
    required this.dropDownValor,
  });

  final String apiValor;
  final String dropDownValor;

 static String getApiValorByDropDownValor(String dropDownValue) {
  for (Filter filter in Filter.values) {
    if (filter.dropDownValor == dropDownValue) {
      return filter.apiValor;
    }
  }
  return '';
}


}
