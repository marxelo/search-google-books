import 'package:flutter/material.dart';
import 'package:gbooks/components/standard_cover_widget.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/pages/book_details.dart';
import 'package:gbooks/utils/tools.dart';

class BookListTileWidget extends StatefulWidget {
  const BookListTileWidget({super.key, required this.book});
  final Book book;

  @override
  State<BookListTileWidget> createState() => _BookListTileWidgetState();
}

class _BookListTileWidgetState extends State<BookListTileWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetail(
              book: widget.book,
            ),
          ),
        );
      },
      child: ListTile(tileColor: Colors.white,
        title: Card(
          color: Colors.white,
          surfaceTintColor: Colors.white,
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
                            widget.book.volumeInfo.title,
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
                                widget.book.volumeInfo.authors),
                            overflow: TextOverflow.clip,
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            widget.book.volumeInfo.publishedDate,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ],
                    ),
                  ),
                  widget.book.volumeInfo.imageLinks.thumbnail.trim().isEmpty
                      ? StandardCoverWidget(
                          book: widget.book,
                        )
                      : ClipRRect(
                          // width: 70,
                          child: Image.network(
                            widget.book.volumeInfo.imageLinks.thumbnail,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
