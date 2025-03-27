import 'package:book_swap/models/book.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_swap/providers/book_provider.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _creditController;
  late final TextEditingController _priceController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.book.name);
    _descController = TextEditingController(text: widget.book.description);
    _creditController =
        TextEditingController(text: widget.book.credit.toString());
    _priceController =
        TextEditingController(text: widget.book.price.toStringAsFixed(2));
  }

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final credit = int.tryParse(_creditController.text) ?? widget.book.credit;
      final price = double.tryParse(_priceController.text) ?? widget.book.price;

      await Provider.of<BookProvider>(context, listen: false).editBook(
        id: widget.book.id,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        credit: credit,
        price: price,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to update: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Book Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Book Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _creditController,
              decoration: const InputDecoration(
                labelText: 'Condition (1-10)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final credit = int.tryParse(value ?? '');
                if (credit == null || credit < 1 || credit > 10) {
                  return 'Enter 1-10';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final price = double.tryParse(value ?? '');
                if (price == null || price < 0) {
                  return 'Enter valid price';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text('SAVE CHANGES'),
            ),
          ],
        ),
      ),
    );
  }
}
