import 'package:book_swap/models/book.dart';
import 'package:book_swap/pages/edit_books.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';

class BooksSection extends StatelessWidget {
  const BooksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Books"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: bookProvider.fetchBooks,
          )
        ],
      ),
      body: _buildBody(bookProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/addbooks'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BookProvider bookProvider) {
    if (bookProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: bookProvider.fetchBooks,
      child: bookProvider.books.isEmpty
          ? _buildEmptyState()
          : _buildBookList(bookProvider),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No books available\nAdd a new book to get started!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildBookList(BookProvider bookProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: bookProvider.books.length,
      itemBuilder: (context, index) {
        final book = bookProvider.books[index];
        return _buildBookCard(context, bookProvider, book);
      },
    );
  }

  Widget _buildBookCard(
      BuildContext context, BookProvider provider, Book book) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildBookImage(book),
        title: Text(
          book.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "Condition: ${book.credit} • Price: रू${book.price.toStringAsFixed(2)}",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: _buildActionButtons(context, provider, book),
        onTap: () => _showBookDetails(context, book),
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, BookProvider provider, Book book) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEditButton(context, book),
        const SizedBox(width: 8),
        _buildDeleteButton(context, provider, book.id),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, Book book) {
    return IconButton(
      icon: const Icon(Icons.edit, color: Colors.blue),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditBookScreen(book: book),
        ),
      ),
    );
  }

  Widget _buildBookImage(Book book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        book.image,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: 60,
          height: 60,
          color: Colors.grey.shade200,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(
      BuildContext context, BookProvider provider, String bookId) {
    return IconButton(
      icon: provider.isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.delete_outline, color: Colors.red),
      onPressed: provider.isLoading
          ? null
          : () => _confirmDelete(context, provider, bookId),
    );
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book.name, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailImage(book),
              const SizedBox(height: 16),
              _buildBookInfo(book),
              const SizedBox(height: 16),
              _buildDescription(book),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditBookScreen(book: book),
                    ),
                  );
                },
                child: const Text('EDIT DETAILS'),
              ),
            ],
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

  Widget _buildDetailImage(Book book) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          book.image,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, size: 50),
          ),
        ),
      ),
    );
  }

  Widget _buildBookInfo(Book book) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoItem("Condition", "${book.credit}"),
        _buildInfoItem("Price", "रू${book.price.toStringAsFixed(2)}"),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDescription(Book book) {
    return Text(
      book.description,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey.shade700),
      maxLines: 5,
      overflow: TextOverflow.ellipsis,
    );
  }

  void _confirmDelete(
      BuildContext context, BookProvider provider, String bookId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Book"),
        content: const Text("This action cannot be undone. Are you sure?"),
        actions: [
          TextButton(
            child: const Text("CANCEL"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red,
            ),
            child: const Text("DELETE"),
            onPressed: () async {
              try {
                await provider.deleteBook(bookId);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  _handleError(context, e.toString());
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _handleError(BuildContext context, String error) {
    if (error.contains('Unauthorized')) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Session Expired"),
          content: const Text("Please login again to continue"),
          actions: [
            TextButton(
              child: const Text("LOGIN"),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              ),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${error.replaceAll("Exception: ", "")}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
