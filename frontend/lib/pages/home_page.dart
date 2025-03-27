import 'package:book_swap/models/book.dart';
import 'package:book_swap/pages/add_books.dart';
import 'package:book_swap/pages/search_section.dart';
import 'package:book_swap/providers/book_provider.dart';
import 'package:book_swap/widgets/home_widgets/book_list.dart';
import 'package:book_swap/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch books using BookProvider
    Future.microtask(() {
      Provider.of<BookProvider>(context, listen: false).fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(),
      drawer: const MyDrawer(),
      body: SafeArea(
        child: bookProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : HomeSection(books: bookProvider.books),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBooksSection(),
            ),
          ).then((_) => bookProvider.fetchBooks()); // Refresh after adding
        },
        tooltip: "Add a New Book",
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: const IconThemeData(color: Colors.white),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Book Swap"),
          Text(
            "Find your next read",
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            _showNotifications(context, [
              "This is hard coded notification FYP!",
            ]);
          },
          icon: const Icon(Icons.notifications),
        ),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchSection()),
              );
            },
            icon: const Icon(Icons.search)),
      ],
    );
  }
}

void _showNotifications(dynamic context, List<String> notifications) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        "Notifications",
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: notifications
              .map((notification) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(notification),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("CLOSE"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

class HomeSection extends StatelessWidget {
  final List<Book> books;

  const HomeSection({super.key, required this.books});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Vx.mOnly(left: 32, right: 32, top: 20),
      child: books.isNotEmpty
          ? BookList(books: books)
          : const Center(child: Text("No books available")),
    );
  }
}
