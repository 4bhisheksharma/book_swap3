import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap/providers/book_provider.dart';
import 'package:book_swap/models/book.dart';
import 'package:book_swap/utils/routes.dart';
import 'package:book_swap/widgets/home_widgets/book_list.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _searchController = TextEditingController();
  List<Book> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadBooks() async {
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    if (bookProvider.books.isEmpty) {
      await bookProvider.fetchBooks();
    }
    setState(() {
      _searchResults = bookProvider.books;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    final bookProvider = Provider.of<BookProvider>(context, listen: false);

    setState(() {
      _isSearching = true;
      _searchResults = bookProvider.books.where((book) {
        return book.name.toLowerCase().contains(query) ||
            book.description.toLowerCase().contains(query);
      }).toList();
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Corrected navigation
        ),
        title: const Text("Search", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search books...",
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                          _searchController.text.isEmpty
                              ? "Search for books by title or description"
                              : "No results found for '${_searchController.text}'",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16)),
                    )
                  : BookList(books: _searchResults),
            ),
          ],
        ),
      ),
    );
  }
}
