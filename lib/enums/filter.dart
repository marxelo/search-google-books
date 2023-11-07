enum Filter {
  all(apiValue: 'all', dropDownValue: 'Não filtrar'),
  ebooks(apiValue: 'e-books', dropDownValue: 'E-book'),
  freeEbooks(apiValue: 'free-ebooks', dropDownValue: 'E-book gratuito'),
  full(apiValue: 'full', dropDownValue: 'Gratuito'),
  paidEbooks(apiValue: 'paid-ebooks', dropDownValue: 'E-book pago'),
  partial(apiValue: 'partial', dropDownValue: 'Acesso parcial');

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
