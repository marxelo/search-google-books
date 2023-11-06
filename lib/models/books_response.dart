import 'package:gbooks/models/book.dart';

class BooksResponse {
  final int totalItems;
  final List<Book> items;
  final int statusCode;
  final String messageCode;

  BooksResponse({
    required this.totalItems,
    required this.items,
    required this.statusCode,
    required this.messageCode,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) {
    return BooksResponse(
      statusCode: 200,
      messageCode: '',
      totalItems: json['totalItems'],
      items: json.containsKey('items')
          ? (json['items'] as List).map((item) => Book.fromJson(item)).toList()
          : [],
    );
  }
}
