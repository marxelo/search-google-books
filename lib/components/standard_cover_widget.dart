import 'package:flutter/material.dart';
import 'package:gbooks/extensions/capitalize.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/utils/tools.dart';

class StandardCoverWidget extends StatelessWidget {
  final Book book;
  final double? height;
  final double? width;
  final TextOverflow? authorTextOverflow;
  final double fontSizeIncreaseBy;

  const StandardCoverWidget({
    Key? key,
    required this.book,
    this.height = 160,
    this.width = 120,
    this.fontSizeIncreaseBy = 0.0,
    this.authorTextOverflow = TextOverflow.ellipsis,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        height: height,
        width: width,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(
            color: Colors.grey[200]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                book.volumeInfo.title.capitalize(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14 + fontSizeIncreaseBy,
                ),
              ),
            ),
            Text(
              Tools.handleAuthorsName(book.volumeInfo.authors),
              textAlign: TextAlign.center,
              overflow: authorTextOverflow,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12 + fontSizeIncreaseBy,
              ),
            ),
            Text(
              book.volumeInfo.publishedDate,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 10 + fontSizeIncreaseBy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
