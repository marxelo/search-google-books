class Book {
  final String id;
  final VolumeInfo volumeInfo;
  AccessInfo accessInfo;

  Book({
    required this.id,
    required this.volumeInfo,
    required this.accessInfo,
  });

    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volumeInfo': volumeInfo.toJson(),
      'accessInfo': accessInfo.toJson(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      volumeInfo: VolumeInfo.fromJson(json['volumeInfo']),
      accessInfo: AccessInfo.fromJson(json['accessInfo']),
    );
  }

  static List<Book> filterBooksWithoutViewabilityNoPages(List<Book> books) {
    List<Book> filteredBooks = [];

    for (Book book in books) {
      if (book.accessInfo.viewability != 'NO_PAGES') {
        filteredBooks.add(book);
      }
    }

    return filteredBooks;
  }
}

class VolumeInfo {
  final String title;
  final String subtitle;
  final List<String> authors;
  final String description;
  final int pageCount;
  final ImageLinks imageLinks;
  final String publishedDate;

  VolumeInfo(
      {required this.title,
      required this.subtitle,
      required this.authors,
      required this.description,
      required this.pageCount,
      required this.imageLinks,
      required this.publishedDate});

        Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'authors': authors,
      'description': description,
      'pageCount': pageCount,
      'imageLinks': imageLinks.toJson(),
      'publishedDate': publishedDate,
    };
  }

  factory VolumeInfo.fromJson(Map<String, dynamic> json) {
    return VolumeInfo(
      title: json['title'] ?? 0,
      subtitle: json['subtitle'] ?? '',
      authors: json.containsKey('authors')
          ? (json['authors'] as List).map((author) => author as String).toList()
          : ['Autor não disponível'],
      description: json['description'] ?? 'Não disponível',
      pageCount: json['pageCount'] ?? 0,
      publishedDate: json['publishedDate'] ?? 'Sem data de Publicação',
      imageLinks: json.containsKey('imageLinks')
          ? ImageLinks.fromJson(json['imageLinks'])
          : ImageLinks(thumbnail: ''),
    );
  }
}

class ImageLinks {
  final String thumbnail;

  ImageLinks({
    required this.thumbnail,
  });

  Map<String, dynamic> toJson() {
    return {
      'thumbnail': thumbnail,
    };
  }

  factory ImageLinks.fromJson(Map<String, dynamic> json) {
    return ImageLinks(
      thumbnail: json['thumbnail'] ??
          'https://en.m.wikipedia.org/wiki/File:No_image_available.svg#/media/File%3AImagem_n%C3%A3o_dispon%C3%ADvel.svg',
    );
  }
}

class AccessInfo {
  Epub epub;
  Pdf pdf;
  String webReaderLink;
  String viewability;
  String accessViewStatus;

  AccessInfo({
    required this.epub,
    required this.pdf,
    required this.webReaderLink,
    required this.viewability,
    required this.accessViewStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'epub': epub.toJson(),
      'pdf': pdf.toJson(),
      'webReaderLink': webReaderLink,
      'viewability': viewability,
      'accessViewStatus': accessViewStatus,
    };
  }

  factory AccessInfo.fromJson(Map<String, dynamic> json) {
    return AccessInfo(
      epub: json.containsKey('epub')
          ? Epub.fromJson(json['epub'])
          : Epub(downloadLink: ''),
      pdf: json.containsKey('pdf')
          ? Pdf.fromJson(json['pdf'])
          : Pdf(downloadLink: ''),
      webReaderLink:
          json.containsKey('webReaderLink') ? json['webReaderLink'] : '',
      accessViewStatus: json.containsKey('accessViewStatus')
          ? json['accessViewStatus'].toString().toUpperCase()
          : 'NONE',
      viewability: json.containsKey('viewability')
          ? json['viewability'].toString().toUpperCase()
          : 'NONE',
    );
  }
}

class Epub {
  String downloadLink;

  Epub({required this.downloadLink});

    Map<String, dynamic> toJson() {
    return {
      'downloadLink': downloadLink,
    };
  }

  factory Epub.fromJson(Map<String, dynamic> json) {
    return Epub(
      downloadLink: json['downloadLink'],
    );
  }
}

class Pdf {
  String downloadLink;

  Pdf({required this.downloadLink});


  Map<String, dynamic> toJson() {
    return {
      'downloadLink': downloadLink,
    };
  }

  factory Pdf.fromJson(Map<String, dynamic> json) {
    return Pdf(
      downloadLink: json['downloadLink'],
    );
  }
}
