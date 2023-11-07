import 'package:flutter/material.dart';
import 'package:gbooks/components/book_list_tile_widget.dart';
import 'package:gbooks/components/search_bottom_sheet.dart';
import 'package:gbooks/enums/filter.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/models/books_response.dart';
import 'package:gbooks/models/search.dart';
import 'package:gbooks/services/google_books_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  // int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  final int maxResults = 20;

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
    Filter.full.dropDownValue,
    Filter.freeEbooks.dropDownValue,
    Filter.ebooks.dropDownValue,
    Filter.partial.dropDownValue,
    Filter.all.dropDownValue
  ];

  late String dropdownValue = list.last;

  Future<void> _fetchData(Search search) async {
    setState(() {
      _isLoading = true;

      _error = '';
    });

    try {
      BooksResponse response = await GoogleBooksClient().getBooks(search);

      if (response.statusCode == 200) {
        debugPrint(response.items.length.toString());
        setState(() {
          if (response.items.isNotEmpty) {
            books.addAll(response.items);
            debugPrint(' ============> ${response.totalItems.toString()}');

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
        // _currentPage++;
        search.startIndex += maxResults;

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

    _searchController.text = "Marcelo";

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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        slivers: <Widget>[
          SliverAppBar.large(
            floating: true,
            pinned: true,
            snap: false,
            backgroundColor: Colors.white,
            shadowColor: Colors.black38,
            surfaceTintColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () => showBottomSheet(),
                icon: const Icon(Icons.search_outlined),
              )
            ],
            // expandedHeight: 160.0,
            flexibleSpace: const FlexibleSpaceBar(
              centerTitle: true,
              expandedTitleScale: 2.0,
              title: Text(
                'Ligrá',
                style: TextStyle(color: Colors.black),
              ),
              // background: FlutterLogo(),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == books.length) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return BookListTileWidget(
                    book: books[index],
                  );
                }
              },
              childCount: books.length + (_isLoading ? 1 : 0),
            ),
          )
        ],
      ),
    );
  }
}
