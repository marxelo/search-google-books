import 'package:flutter/material.dart';
import 'package:gbooks/components/standard_cover_widget.dart';
import 'package:gbooks/enums/ownership.dart';
import 'package:gbooks/enums/read_status.dart';
import 'package:gbooks/models/shelf.dart';
import 'package:gbooks/services/gbooks_service.dart';
import 'package:gbooks/utils/constants.dart';
import 'package:gbooks/utils/dbhelper.dart';

class BookDetail extends StatefulWidget {
  const BookDetail({super.key, required this.book});

  final Book book;

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  late Book book;

  late Shelf bookFromShelf;
  bool bookAlreadyOnShelf = false;
  // Shelf? shelf;

  void _saveBookInShelf(Shelf book) async {
    await DbHelper.insert(book);
  }

  void _updateBookInShelf(Shelf book) async {
    await DbHelper.update(book);
  }

  Future<void> _updateOrSaveBookInShelf(Shelf book) async {
    if (book.id == null) {
      _saveBookInShelf(book);
    } else {
      _updateBookInShelf(book);
    }

    _fetchBookFromShelf(widget.book.id);
  }

  Future<void> _fetchBookFromShelf(String externalId) async {
    final shelf = await DbHelper.getASingleBookByExternalId(externalId);

    if (shelf != null) {
      setState(() {
        bookFromShelf.id = shelf.id;
        bookFromShelf.ownership = shelf.ownership;
        bookFromShelf.readStatus = shelf.readStatus;
        bookAlreadyOnShelf = true;
      });
    }
  }

  void _initilizeBookFromShelf() {
    setState(() {
      bookFromShelf = Shelf(
        // id: 0,
        externalId: widget.book.id,
        readStatus: ReadStatus.notRead,
        ownership: Ownership.notOwned,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    book = widget.book;
    _initilizeBookFromShelf();
    _fetchBookFromShelf(widget.book.id);
  }

  String getAuthors() {
    String authors = '';
    for (String author in widget.book.volumeInfo.authors) {
      authors = "$authors $author\n";
    }
    return authors.substring(0, authors.length - 1);
  }

  Widget ownershipWidget(Shelf book) {
    return book.ownership.index == 0
        ? const Column(
            children: [
              Icon(
                Icons.bookmark_border_outlined,
                color: Colors.red,
              ),
              Text('Não Tenho')
            ],
          )
        : const Column(
            children: [
              Icon(
                Icons.bookmark_added_outlined,
                color: Colors.green,
              ),
              Text('Tenho')
            ],
          );
  }

  Widget readStatusWidget(Shelf book) {
    return book.readStatus.index == 0
        ? const Column(
            children: [
              Icon(
                Icons.chrome_reader_mode_outlined,
                color: Colors.red,
              ),
              Text('Não Li')
            ],
          )
        : const Column(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: Colors.green,
              ),
              Text('Já Li')
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              height: 300,
              alignment: Alignment.center,
              child: book.volumeInfo.imageLinks.thumbnail.isEmpty
                  ? StandardCoverWidget(
                      book: book,
                      height: 300,
                      width: 220,
                      fontSizeIncreaseBy: 5,
                      authorTextOverflow: TextOverflow.clip,
                    )
                  : Image.network(
                      book.volumeInfo.imageLinks.thumbnail,
                      fit: BoxFit.fitHeight,
                      height: 300,
                    ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                book.volumeInfo.title,
                style: const TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 30.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (bookFromShelf.ownership == Ownership.owned) {
                        bookFromShelf.ownership = Ownership.notOwned;
                      } else {
                        bookFromShelf.ownership = Ownership.owned;
                      }
                      _updateOrSaveBookInShelf(bookFromShelf);
                      setState(() {
                        bookFromShelf;
                      });
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                          // minHeight: 100,
                          minWidth: 60,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity),
                      child: ownershipWidget(bookFromShelf),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (bookFromShelf.readStatus == ReadStatus.read) {
                        bookFromShelf.readStatus = ReadStatus.notRead;
                      } else {
                        bookFromShelf.readStatus = ReadStatus.read;
                      }
                      _updateOrSaveBookInShelf(bookFromShelf);
                      setState(() {
                        bookFromShelf;
                      });
                    },
                    child: Container(
                      constraints: const BoxConstraints(
                          // minHeight: 100,
                          minWidth: 60,
                          maxWidth: double.infinity,
                          maxHeight: double.infinity),
                      child: readStatusWidget(bookFromShelf),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 100,
                    minWidth: 300,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Informações do Livro',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Icon(
                            book.volumeInfo.authors.length < 2
                                ? Icons.person_outlined
                                : Icons.people_alt_outlined,
                            color: kDetailsIconColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              getAuthors(),
                              style: kDetailsTextStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: kDetailsIconColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              book.volumeInfo.publishedDate,
                              style: kDetailsTextStyle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          const Icon(
                            Icons.numbers_outlined,
                            color: kDetailsIconColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            book.volumeInfo.pageCount > 0
                                ? '${book.volumeInfo.pageCount.toString()} páginas'
                                : 'Não disponível',
                            style: kDetailsTextStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          // const Text('E-mail: '),
                          const Icon(
                            Icons.notes_outlined,
                            color: kDetailsIconColor,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              book.volumeInfo.description,
                              style: const TextStyle(
                                // color: Colors.black87,

                                fontSize: 16,
                                overflow: TextOverflow.clip,
                                // fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ]),
        ),
      ),
    );
  }
}
