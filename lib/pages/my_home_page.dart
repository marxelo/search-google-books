import 'package:flutter/material.dart';
import 'package:gbooks/components/book_list_tile_widget.dart';
import 'package:gbooks/components/search_bottom_sheet.dart';
import 'package:gbooks/enums/filter.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/models/books_response.dart';
import 'package:gbooks/models/search.dart';
import 'package:gbooks/services/gbooks_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();

  late List<Book> books = [];

  Search search = Search(query: '');

  String _error = '';

  final googleBooksClient = GoogleBooksClient();
  final int _numberOfBooksPerRequest = 20;
  bool _finalPage = false;

  bool _isLoading = false;
  bool _toastMessageSent = false;
  bool _portugueseOnly = false;

  final List<String> list = <String>[
    Filter.full.dropDownValor,
    Filter.freeEbooks.dropDownValor,
    Filter.ebooks.dropDownValor,
    Filter.partial.dropDownValor,
    Filter.all.dropDownValor
  ];

  late String dropdownValue = list.first;

  Future<void> _fetchData(Search search) async {
    setState(() {
      _isLoading = true;

      _error = '';
    });

    try {
      BooksResponse response = await GoogleBooksClient().getBooks(search);

      if (response.statusCode == 200) {
        debugPrint(response.toString());
        setState(() {
          if (response.items.isNotEmpty) {
            books.addAll(response.items);

            if (response.items.length < _numberOfBooksPerRequest) {
              _finalPage = true;
            }
            if (response.items.isEmpty) {
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

  Future<void> _onSearchPressed() async {
    if (_searchController.text.isNotEmpty) {
      search.query = _searchController.text;
      search.startIndex = 0;
      search.inBrazilianPortugueseOnly = _portugueseOnly;
      search.filter = Filter.getApiValorByDropDownValor(dropdownValue);
      books = [];
      _finalPage = false;
      _toastMessageSent = false;
      _fetchData(search);
    }

    _searchController.text = "";

    Navigator.of(context).pop();
  }

  void showBottomSheet() async {
    _searchController.text = search.query;
    showModalBottomSheet(
      elevation: 5,
      shape: const ContinuousRectangleBorder(
        borderRadius: BorderRadiusDirectional.zero,
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SearchBottomSheet(
          searchController: _searchController,
          portugueseOnly: _portugueseOnly,
          dropdownValue: dropdownValue,
          onSearchPressed: _onSearchPressed,
          onPortugueseOnlyChanged: (newValue) {
            setState(() {
              _portugueseOnly = newValue!;
            });
          },
          onDropdownValueChanged: (value) {
            setState(() {
              dropdownValue = value!;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ligrá"),
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
                  return BookListTileWidget(
                    book: books[index],
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
