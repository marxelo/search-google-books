import 'package:flutter/material.dart';
import 'package:gbooks/pages/book_details.dart';
import 'package:gbooks/services/gbooks_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Book> books = [];

  final googleBooksClient = GoogleBooksClient();

  bool _isLoading = false;

  void _getBooks(String query) async {
    _isLoading = true;
    final booksResponse = await googleBooksClient.getBooks(query);

    setState(() {
      _isLoading = false;
      books = booksResponse.items;
    });
  }

  @override
  void initState() {
    super.initState();
    // _getBooks('Android');
  }

  final TextEditingController _searchController = TextEditingController();

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
                hintText: "Contém no título",
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_searchController.text.isNotEmpty) {
                    _getBooks(_searchController.text);
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) => Card(
                margin: const EdgeInsets.all(5),
                child: GestureDetector(
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
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(),
        child: const Icon(Icons.search_outlined),
      ),
    );
  }
}
