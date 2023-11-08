import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gbooks/models/books_response.dart';
import 'package:gbooks/models/search.dart';
import 'package:http/http.dart' as http;

class GoogleBooksClient {
  final String baseUrl =
      'https://www.googleapis.com/books/v1/volumes?q=+intitle:';
  final String urlSuffix =
      '&maxResults=20&fields=totalItems,items/id,items/volumeInfo(title,authors,publishedDate,description,pageCount,imageLinks/thumbnail),items/accessInfo(viewability,epub/downloadLink,pdf/downloadLink,webReaderLink,accessViewStatus)';
  final String portugueseOnlyQueryParam = '&langRestrict=pt';

  Future<BooksResponse> getBooks(Search search) async {
    // debugPrint(search.toString());

    String fullUrl =
        '$baseUrl${search.query}&startIndex=${search.startIndex.toString()}$urlSuffix';

    if (search.language != 'all') {
      fullUrl += '&langRestrict=${search.language}';
    }

    if (search.filter != 'Não Filtrar' && search.filter != 'all' ) {
      fullUrl += '&filter=${search.filter}';
    }

    Uri uri = Uri.parse(fullUrl);

    debugPrint(uri.toString());

    final response = await http.get(uri);

    debugPrint(response.toString());
    if (response.statusCode == 200) {
      return BooksResponse.fromJson(jsonDecode(response.body));
    } else {
      return BooksResponse(
          totalItems: 0,
          items: [],
          statusCode: response.statusCode,
          messageCode: 'Erro ao buscar livros: ${response.statusCode}');
      // throw Exception('Failed to get books: ${response.statusCode}');
    }
  }
}
