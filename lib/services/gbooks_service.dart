import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class GoogleBooksClient {
  final String baseUrl =
      'https://www.googleapis.com/books/v1/volumes?q=+intitle:';
  final String urlSuffix =
      '&startIndex=0&maxResults=20&langRestrict=pt-BR&fields=totalItems,items/id,items/volumeInfo(title,authors,description,pageCount,imageLinks)';

  Future<BooksResponse> getBooks(String query) async {
    String fullUrl = baseUrl + query + urlSuffix;
    // Uri uri = Uri.parse(baseUrl).replace(queryParameters: {'q': query});
    Uri uri = Uri.parse(fullUrl);
    // print(uri.toString());

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return BooksResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get books: ${response.statusCode}');
    }
  }
}

class BooksResponse {
  final int totalItems;
  final List<Book> items;

  BooksResponse({
    required this.totalItems,
    required this.items,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) {
    return BooksResponse(
      totalItems: json['totalItems'],
      items: json.containsKey('items')
          ? (json['items'] as List).map((item) => Book.fromJson(item)).toList()
          : [],
    );
  }
}

class Book {
  final String id;
  final VolumeInfo volumeInfo;

  Book({
    required this.id,
    required this.volumeInfo,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      volumeInfo: VolumeInfo.fromJson(json['volumeInfo']),
    );
  }
}

class VolumeInfo {
  final String title;
  final List<String> authors;
  final String description;
  final int pageCount;
  final ImageLinks imageLinks;
  final String publishedDate;

  VolumeInfo(
      {required this.title,
      required this.authors,
      required this.description,
      required this.pageCount,
      required this.imageLinks,
      required this.publishedDate});

  factory VolumeInfo.fromJson(Map<String, dynamic> json) {
    return VolumeInfo(
      title: json['title'] ?? 0,
      authors: json.containsKey('authors')
          ? (json['authors'] as List).map((author) => author as String).toList()
          : ['Autor não disponível'],
      description: json['description'] ?? 'Não disponível',
      pageCount: json['pageCount'] ?? 0,
      publishedDate: json['publishedDate'] ?? 'Sem data de Publicação',
      imageLinks: json.containsKey('imageLinks')
          ? ImageLinks.fromJson(json['imageLinks'])
          : ImageLinks(
              smallThumbnail:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Imagem_n%C3%A3o_dispon%C3%ADvel.svg/240px-Imagem_n%C3%A3o_dispon%C3%ADvel.svg.png',
              thumbnail:
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Imagem_n%C3%A3o_dispon%C3%ADvel.svg/240px-Imagem_n%C3%A3o_dispon%C3%ADvel.svg.png'),
    );
  }
}

class ImageLinks {
  final String smallThumbnail;
  final String thumbnail;

  ImageLinks({
    required this.smallThumbnail,
    required this.thumbnail,
  });

  factory ImageLinks.fromJson(Map<String, dynamic> json) {
    return ImageLinks(
      smallThumbnail: json['smallThumbnail'] ??
          'https://en.m.wikipedia.org/wiki/File:No_image_available.svg#/media/File%3AImagem_n%C3%A3o_dispon%C3%ADvel.svg',
      thumbnail: json['thumbnail'] ??
          'https://en.m.wikipedia.org/wiki/File:No_image_available.svg#/media/File%3AImagem_n%C3%A3o_dispon%C3%ADvel.svg',
    );
  }
}
