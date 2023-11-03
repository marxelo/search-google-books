import 'package:flutter/material.dart';
import 'package:gbooks/services/gbooks_service.dart';
import 'package:gbooks/utils/constants.dart';

class BookDetail extends StatefulWidget {
  const BookDetail({super.key, required this.book});

  final Book book;

  @override
  State<BookDetail> createState() => _BookDetailState();
}

class _BookDetailState extends State<BookDetail> {
  late Book book;

  @override
  void initState() {
    super.initState();
    book = widget.book;
    // fetchData();
  }

  String getAuthors() {
    String authors = '';
    for (String author in widget.book.volumeInfo.authors) {
      authors = "$authors $author\n";
    }
    return authors.substring(0, authors.length - 1);
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
              height: 250,
              alignment: Alignment.center,
              child: Image.network(
                book.volumeInfo.imageLinks.thumbnail,
                fit: BoxFit.fitHeight,
                height: 250,
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
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(
                    minHeight: 100,
                    minWidth: 300,
                    maxWidth: double.infinity,
                    maxHeight: double.infinity),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(76, 199, 198, 198),
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Informações do Livro',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outlined,
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
                                  color: Colors.black87,
                                  fontSize: 16,
                                  overflow: TextOverflow.clip,
                                  fontWeight: FontWeight.normal),
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
