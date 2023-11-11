import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gbooks/models/book.dart';
import 'package:gbooks/models/shelf.dart';
import 'package:gbooks/pages/book_details.dart';
import 'package:gbooks/utils/dbhelper.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});

  final String title;

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  List<Shelf> dataList = [];

  late Book buk;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  void _fetchBooks() async {
    final List<Shelf> bookList = await DbHelper.getAllBooksFromShelf();

    setState(() {
      dataList = bookList;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        primary: false,
        slivers: <Widget>[
          const SliverAppBar(
            title: Text('Minha Estante'),
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350.0,
                mainAxisExtent: 250,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  Book book2 = Book.fromJson(
                    jsonDecode(
                      dataList[index].bookData,
                    ),
                  );
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetail(
                            book: book2,
                          ),
                        ),
                      ).then((result) {
                            _fetchBooks();
                        });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: Image.network(
                                book2.volumeInfo.imageLinks.thumbnail,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text(
                              book2.volumeInfo.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: dataList.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
