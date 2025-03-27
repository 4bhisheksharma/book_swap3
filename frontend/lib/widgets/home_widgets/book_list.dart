import 'dart:ui';
import 'package:book_swap/models/book.dart';
import 'package:flutter/material.dart';

class BookList extends StatelessWidget {
  final List<Book> books;

  const BookList({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return ListTile(
          leading: Image.network(
            book.image, // Use property access
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
          title: Text(book.name),
          subtitle: Text("Credits: ${book.credit}"),
        );
      },
    );
  }
}
