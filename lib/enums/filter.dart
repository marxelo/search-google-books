enum Filter {
  full(apiValue: 'full', dropDownValue: 'Gratuito'),
  freeEbooks(apiValue: 'free-ebooks', dropDownValue: 'E-book gratuito'),
  partial(apiValue: 'partial', dropDownValue: 'Acesso parcial'),
  ebooks(apiValue: 'ebooks', dropDownValue: 'E-book'),
  paidEbooks(apiValue: 'paid-ebooks', dropDownValue: 'E-book pago'),
  all(apiValue: 'all', dropDownValue: 'Não filtrar');

  const Filter({
    required this.apiValue,
    required this.dropDownValue,
  });

  final String apiValue;
  final String dropDownValue;

  static String getApiValorByDropDownValor(String dropDownValue) {
    for (Filter filter in Filter.values) {
      if (filter.dropDownValue == dropDownValue) {
        return filter.apiValue;
      }
    }
    return '';
  }
}
