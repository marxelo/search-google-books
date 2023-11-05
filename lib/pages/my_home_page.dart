import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gbooks/components/standard_cover_widget.dart';
import 'package:gbooks/models/search.dart';
import 'package:gbooks/pages/book_details.dart';
import 'package:gbooks/services/gbooks_service.dart';
import 'package:gbooks/utils/tools.dart';
import 'package:http/http.dart' as http;

const String baseUrl =
    'https://www.googleapis.com/books/v1/volumes?q=+intitle:';
const String urlSuffix =
    '&maxResults=20&fields=totalItems,items/id,items/volumeInfo(title,authors,publishedDate,description,pageCount,imageLinks/thumbnail),items/accessInfo(epub/downloadLink,pdf/downloadLink,webReaderLink)';
const String portugueseOnlyQueryParam = '&langRestrict=pt';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Menu Button');
  // static const SingleActivator _showShortcut =
  //     SingleActivator(LogicalKeyboardKey.keyS, control: true);
  final _scrollController = ScrollController();
  int _currentPage = 0;
  // final _list = <String>[];
  final TextEditingController _searchController = TextEditingController();

  late List<Book> books = [];

  Search search = Search(query: '');

  String _error = '';

  final googleBooksClient = GoogleBooksClient();
  final int _numberOfBooksPerRequest = 20;
  bool _finalPage = false;

  bool _isLoading = false;
  bool _toastMessageSent = false;
  bool _portugueseOnly = true;
  bool _eBooks = false;

  Future<void> _fetchData(Search s) async {
    setState(() {
      _isLoading = true;

      _error = '';
    });

    try {
      String fullUrl =
          '$baseUrl${s.query}&startIndex=${s.startIndex.toString()}$urlSuffix';

      if (_portugueseOnly) {
        fullUrl += portugueseOnlyQueryParam;
      }

      String filter = '&filter=full';

      if (_eBooks) {
        filter = '&filter=free-ebooks';
      }

      fullUrl += filter;

      Uri uri = Uri.parse(fullUrl);

      print('uri: ${uri.toString()}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          if (response.body.isNotEmpty) {
            final bResponse = BooksResponse.fromJson(jsonDecode(response.body));
            books.addAll(bResponse.items);

            if (bResponse.items.length < _numberOfBooksPerRequest) {
              _finalPage = true;
            }
            if (bResponse.items.isEmpty) {
              _showSnackBar(context, 'Não encontrado');
            }
          } else {
            _finalPage = true;
            _showSnackBar(context, 'Não encontrado');
          }
          _isLoading = false;
          _error = '';
        });
      } else {
        throw Exception('Failed to load data');
      }
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;

        _error = e.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    _portugueseOnly;
    _eBooks;
    // _getBooks('Android');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (_finalPage) {
      if (!_toastMessageSent) {
        _toastMessageSent = true;
        _showSnackBar(
            context, 'Não encontrados mais livros com estes critérios');
      }
    } else {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _currentPage++;
        search.startIndex = _currentPage;

        _fetchData(search);
      }
    }
  }

  Future<void> _showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void showBottomSheet() async {
    showModalBottomSheet(
      // backgroundColor: Colors.grey,
      elevation: 5,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadiusDirectional.zero,
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextFormField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onEditingComplete: () async {
                  if (_searchController.text.isNotEmpty) {
                    search.query = _searchController.text;
                    search.startIndex = 0;
                    books = [];
                    _finalPage = false;
                    _toastMessageSent = false;
                    _fetchData(search);
                  }

                  _searchController.text = "";

                  Navigator.of(context).pop();
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Palavra contida no título",
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CheckboxMenuButton(
                    value: _portugueseOnly,
                    onChanged: (bool? newValue) {
                      setState(
                        () {
                          _portugueseOnly = newValue!;
                        },
                      );
                    },
                    child: const Text('Apenas português'),
                  ),
                  CheckboxMenuButton(
                    value: _eBooks,
                    onChanged: (bool? newValue) {
                      setState(
                        () {
                          _eBooks = newValue!;
                        },
                      );
                    },
                    child: const Text('e-books'),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // String _handleAuthorsName(List<String> authors) {
  //   if (authors.isEmpty) {
  //     return 'Autor não disponível';
  //   } else if (authors.length == 1) {
  //     return authors.first;
  //   } else if (authors.length == 2) {
  //     return '${authors[0]} e ${authors[1]}';
  //   }
  //   return '${authors.first} e outros';
  // }

  // Widget noCoverImageWidget(Book book) {
  //   return ClipRRect(
  //     child: Container(
  //       height: 150,
  //       width: 130,
  //       padding: const EdgeInsets.all(16.0),
  //       decoration: BoxDecoration(
  //         border: Border.all(
  //           color: Colors.black54,
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: Text(
  //               book.volumeInfo.title.capitalize(),
  //               textAlign: TextAlign.center,
  //               overflow: TextOverflow.clip,

  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 14,
  //               ),
  //             ),
  //           ),
  //           Text(
  //             Tools.handleAuthorsName(book.volumeInfo.authors),
  //             textAlign: TextAlign.center,
  //             overflow: TextOverflow.clip,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.normal,
  //               fontSize: 12,
  //             ),
  //           ),
  //           Text(
  //             book.volumeInfo.publishedDate,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.normal,
  //               fontSize: 10,
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text("gBooks"),
      ),
      body: _error.isNotEmpty
          ? Center(child: Text('Error: $_error'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: books.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == books.length) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetail(
                            book: books[index],
                          ),
                        ),
                      );
                    },
                    child: ListTile(
                      title: Card(
                        surfaceTintColor:
                            Theme.of(context).colorScheme.background,
                        margin: const EdgeInsets.fromLTRB(0.0, 2.0, 0.0, 2.0),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            constraints: const BoxConstraints(
                                minHeight: 150,
                                minWidth: 320,
                                maxWidth: double.infinity,
                                maxHeight: double.infinity),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          books[index].volumeInfo.title,
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.clip,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          Tools.handleAuthorsName(
                                              books[index].volumeInfo.authors),
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          books[index].volumeInfo.publishedDate,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                books[index]
                                        .volumeInfo
                                        .imageLinks
                                        .thumbnail
                                        .trim()
                                        .isEmpty
                                    ? StandardCoverWidget(
                                        book: books[index],
                                      )
                                    : ClipRRect(
                                        // width: 70,
                                        child: Image.network(books[index]
                                            .volumeInfo
                                            .imageLinks
                                            .thumbnail),
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
      //
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(),
        child: const Icon(Icons.search_outlined),
      ),
    );
  }
}
