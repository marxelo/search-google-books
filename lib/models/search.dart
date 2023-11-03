import 'package:gbooks/enums/filter.dart';
import 'package:gbooks/enums/order.dart';

class Search {
   String query;
   String excludedTerm;
   int startIndex;
  final int maxResults;
  final bool inTitleOnly;
  final bool inBrazilianPortugueseOnly;
  final Filter filter;
  final Order order;

   Search({
    required this.query,
    this.excludedTerm = '',
    this.startIndex = 0,
    this.maxResults = 10,
    this.inTitleOnly = false,
    this.inBrazilianPortugueseOnly = false,
    this.filter = Filter.ebooks,
    this.order = Order.relevance,
  });

  // ... getters and setters ...
}