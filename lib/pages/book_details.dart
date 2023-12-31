import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gbooks/components/standard_cover_widget.dart';
import 'package:gbooks/components/web_view_container.dart';
import 'package:gbooks/enums/ownership.dart';
import 'package:gbooks/enums/read_status.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/models/shelf.dart';
import 'package:gbooks/utils/constants.dart';
import 'package:gbooks/utils/dbhelper.dart';
import 'package:url_launcher/url_launcher.dart';

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

  void _saveBookInShelf(Shelf book) async {
    await DbHelper.insert(book);
    setState(() {
      _showSnackBar(context, 'Livro guardado na sua estante');
    });
    _fetchBookFromShelf(widget.book.id);
  }

  void _updateBookInShelf(Shelf book) async {
    await DbHelper.update(book);
  }

  void _delete(int id) async {
    await DbHelper.delete(id);

    setState(() {
      _showSnackBar(context, 'Livro retirado da sua estante');
      bookAlreadyOnShelf = false;
      _initilizeBookFromShelf();
    });
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
        bookData: jsonEncode(widget.book.toJson()),
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

  Widget iconActionWidget(
    IconData icon,
    Color color,
    String name,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
        ),
        Text(
          name,
        ),
      ],
    );
  }

  Widget accessViewWidget(String viewability) {
    return iconActionWidget(
        Icons.local_library_outlined,
        viewability.contains('FULL') || viewability.contains('ALL_PAGES')
            ? Colors.green
            : Colors.yellow,
        'Ler');
  }

  Widget ownershipWidget(Shelf book) {
    return book.ownership.index == 0
        ? iconActionWidget(
            Icons.sell_outlined,
            Colors.red,
            'Não Tenho',
          )
        : iconActionWidget(
            Icons.sell_outlined,
            Colors.green,
            'Tenho',
          );
  }

  Widget readStatusWidget(Shelf book) {
    return book.readStatus.index == 0
        ? iconActionWidget(
            Icons.chrome_reader_mode_outlined,
            Colors.red,
            'Não li',
          )
        : iconActionWidget(
            Icons.fact_check_outlined,
            Colors.green,
            'Já li',
          );
  }

  Future<void> _downloadEpub() async {
    Uri uri = Uri.parse(book.accessInfo.epub.downloadLink);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _downloadPdf() async {
    Uri uri = Uri.parse(book.accessInfo.pdf.downloadLink);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (book.accessInfo.webReaderLink.isNotEmpty &&
                        book.accessInfo.accessViewStatus != 'NONE')
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewContainer(
                                book: book,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 60,
                              maxWidth: double.infinity,
                              maxHeight: double.infinity),
                          child: accessViewWidget(
                              widget.book.accessInfo.viewability),
                        ),
                      ),
                    if (book.accessInfo.epub.downloadLink.isNotEmpty)
                      GestureDetector(
                        onTap: _downloadEpub,
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 60,
                              maxWidth: double.infinity,
                              maxHeight: double.infinity),
                          child: iconActionWidget(
                            Icons.download_outlined,
                            Colors.blue,
                            'EPUB',
                          ),
                        ),
                      ),
                    if (book.accessInfo.pdf.downloadLink.isNotEmpty)
                      GestureDetector(
                        onTap: _downloadPdf,
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 60,
                              maxWidth: double.infinity,
                              maxHeight: double.infinity),
                          child: iconActionWidget(
                            Icons.download_outlined,
                            Colors.blue,
                            'PDF',
                          ),
                        ),
                      ),
                    //
                    !bookAlreadyOnShelf
                        ? GestureDetector(
                            onTap: () {
                              _saveBookInShelf(bookFromShelf);
                            },
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 60,
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity),
                              child: iconActionWidget(
                                Icons.shelves,
                                Colors.blue,
                                'Guardar',
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: () {
                              _delete(bookFromShelf.id!);
                            },
                            child: Container(
                              constraints: const BoxConstraints(
                                  minWidth: 60,
                                  maxWidth: double.infinity,
                                  maxHeight: double.infinity),
                              child: iconActionWidget(
                                Icons.shelves,
                                Colors.red,
                                'Retirar',
                              ),
                            ),
                          ),
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
                            minWidth: 60,
                            maxWidth: double.infinity,
                            maxHeight: double.infinity),
                        child: ownershipWidget(bookFromShelf),
                      ),
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
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 100,
                    minWidth: 300,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: kAboutBookSizedBoxHeight),
                      const Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Sobre este livro',
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: kAboutBookSizedBoxHeight),
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
                      const SizedBox(height: kAboutBookSizedBoxHeight),
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
                      const SizedBox(height: kAboutBookSizedBoxHeight),
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
                      const SizedBox(height: kAboutBookSizedBoxHeight),
                      Row(
                        children: [
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
                                fontSize: 16,
                                overflow: TextOverflow.clip,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: kAboutBookSizedBoxHeight),
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
