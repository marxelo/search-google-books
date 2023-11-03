import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gbooks/models/search.dart';
import 'package:gbooks/pages/book_details.dart';
import 'package:gbooks/services/gbooks_service.dart';
import 'package:http/http.dart' as http;

const String baseUrl =
    'https://www.googleapis.com/books/v1/volumes?q=+intitle:';
const String urlSuffix =
    '&maxResults=20&langRestrict=pt-BR&fields=totalItems,items/id,items/volumeInfo(title,authors,description,pageCount,imageLinks)';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  int _currentPage = 0;
  // final _list = <String>[];
  final TextEditingController _searchController = TextEditingController();

  late List<Book> books = [];

  Search search = Search(query: '');

  String _error = '';

  final googleBooksClient = GoogleBooksClient();

  bool _isLoading = false;

  Future<void> _fetchData(Search s) async {
    setState(() {
      _isLoading = true;

      _error = '';
    });

    try {
      String fullUrl =
          '$baseUrl${s.query}&startIndex=${s.startIndex.toString()}$urlSuffix';

      Uri uri = Uri.parse(fullUrl);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        setState(() {
          if (response.body.isNotEmpty ) {
            final bResponse = BooksResponse.fromJson(jsonDecode(response.body));
            books.addAll(bResponse.items);
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
    // _getBooks('Android');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      search.startIndex = _currentPage;

      _fetchData(search);
    }
  }

  void showBottomSheet() async {
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 30,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              controller: _searchController,
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Palavra contida no título",
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_searchController.text.isNotEmpty) {
                    search.query = _searchController.text;
                    search.startIndex = 0;
                    books = [];
                    _fetchData(search);
                  }

                  _searchController.text = "";

                  Navigator.of(context).pop();
                },
                child: const Padding(
                  padding: EdgeInsets.all(18),
                  child: Text(
                    "Pesquisar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
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
                      // visualDensity: VisualDensity.comfortable,
                      leading: Image.network(
                          books[index].volumeInfo.imageLinks.thumbnail),
                      title: SizedBox(
                        // height: 80,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Text(
                            books[index].volumeInfo.title, // aki
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                        ),
                      ),
                      subtitle: Text(books[index].volumeInfo.authors.length > 1
                          ? '${books[index].volumeInfo.authors[0]} e outro(s) '
                          : books[index].volumeInfo.authors[0]), //aki
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
