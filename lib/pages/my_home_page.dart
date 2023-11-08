import 'package:flutter/material.dart';
import 'package:gbooks/components/book_list_tile_widget.dart';
import 'package:gbooks/components/search_bottom_sheet.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final int maxResults = 20;

  late List<Book> books = [];

  Search search = Search(query: '');

  String _error = '';

  final googleBooksClient = GoogleBooksClient();
  bool _finalPage = false;

  bool _isLoading = false;
  bool _toastMessageSent = false;

  late String _selectedFilter = 'all';
  late String _selectedLanguage = 'all';

  Future<void> _fetchAndFilterBooks(Search search) async {
    setState(() {
      _isLoading = true;

      _error = '';
    });

    List<Book> tempBookList = [];

    while (tempBookList.length < maxResults && !_finalPage) {
      List<Book> response = await _fetchBooks(search);

      if (response.isNotEmpty) {
        tempBookList
            .addAll(Book.filterBooksWithoutViewabilityNoPages(response));
      }

      if (response.length < maxResults) {
        _finalPage = true;
      }

      search.startIndex += maxResults;
    }
    books.addAll(tempBookList);
    setState(() {
      _isLoading = false;
    });
  }

  Future<List<Book>> _fetchBooks(Search search) async {
    List<Book> empty = [];
    try {
      BooksResponse response = await GoogleBooksClient().getBooks(search);

      if (response.statusCode == 200) {
        if (response.items.isNotEmpty) {
          return response.items;
        }
      }

      return empty;
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;

        _error = e.toString();
        _showSnackBar(context, _error);
      });
      return empty;
    }
  }


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
    _selectedFilter = 'full';
    _selectedLanguage = 'all';
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
        search.startIndex += maxResults;

        // _fetchData(search); // aki
        _fetchAndFilterBooks(search);
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

  Future<void> _onLanguageSelection(newValue) async {
    _selectedLanguage = newValue.toString();
  }

  Future<void> _onFilterSelection(newValue) async {
    _selectedFilter = newValue.toString();
  }

  Future<void> _onSearchPressed() async {
    if (_searchController.text.isNotEmpty) {
      search.query = _searchController.text;
      search.startIndex = 0;
      search.language = _selectedLanguage;
      search.filter = _selectedFilter;
      books = [];
      _finalPage = false;
      _toastMessageSent = false;
      // _fetchData(search); // aki
      _fetchAndFilterBooks(search);
    }

    _searchController.text = "Marcelo";

    Navigator.of(context).pop();
  }

  void showBottomSheet() async {
    _searchController.text = search.query;
    showModalBottomSheet(
      elevation: 5,
      isScrollControlled: true,
      context: context,
      enableDrag: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) {
        return SearchBottomSheet(
          searchController: _searchController,
          selectedLanguage: _selectedLanguage,
          onSearchPressed: _onSearchPressed,
          onLanguageSelection: _onLanguageSelection,
          onFilterSelection: _onFilterSelection,
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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 10),
              title: const Text(
                'Ligrá',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              expandedTitleScale: 3.0,
              background: AnimatedContainer(
                width: 250,
                height: 250,
                duration: const Duration(
                  milliseconds: 1000,
                ),
                curve: Curves.ease,
                child: Image.asset(
                  'assets/appbar_bg.png',
                  colorBlendMode: BlendMode.softLight,
                  color: Colors.white,
                  centerSlice: Rect.largest,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (index == books.length) {
                  return const SizedBox(
                    height: 600,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
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
