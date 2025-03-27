import 'dart:io';
import 'package:book_swap/providers/book_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddBooksSection extends StatefulWidget {
  const AddBooksSection({super.key});

  @override
  State<AddBooksSection> createState() => _AddBooksSectionState();
}

class _AddBooksSectionState extends State<AddBooksSection> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _priceController = TextEditingController();
  final _creditController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  File? _imageFile;
  bool _isSubmitting = false;
  bool _hasAttemptedSubmit = false;

  @override
  void dispose() {
    _priceController.dispose();
    _creditController.dispose();
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (pickedFile != null && mounted) {
        setState(() => _imageFile = File(pickedFile.path));
      }
    } catch (e) {
      _showError(
          'Image selection failed: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> _submitForm() async {
    setState(() => _hasAttemptedSubmit = true);

    if (!_formKey.currentState!.validate() || _imageFile == null) {
      if (_imageFile == null) {
        _showError('Please select a book image');
      }
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      await Provider.of<BookProvider>(context, listen: false).addBook(
        _titleController.text.trim(),
        _descController.text.trim(),
        int.parse(_creditController.text),
        double.parse(_priceController.text.replaceAll(RegExp(r'[^0-9.]'), '')),
        _imageFile!,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _handleError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleError(String error) {
    final message = error.replaceAll('Exception: ', '');
    if (message.contains('Unauthorized') ||
        message.contains('Session expired')) {
      _showTokenExpiredDialog();
    } else {
      _showError('Submission failed: $message');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _showTokenExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
            'Your session has expired. Please log in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            ),
            child: const Text('LOGIN NOW'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
        ),
        title: const Text("Add New Book"),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildTitleField(),
                const SizedBox(height: 20),
                _buildDescriptionField(),
                const SizedBox(height: 20),
                _buildCreditField(),
                const SizedBox(height: 20),
                _buildPriceField(),
                const SizedBox(height: 24),
                _buildImageUploadSection(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Book Title',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter a book title' : null,
      maxLength: 100,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descController,
      decoration: const InputDecoration(
        labelText: 'Description',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
        hintText:
            'Describe the book condition, edition, and special features...',
      ),
      maxLines: 4,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter a description';
        // if (value!.length < 30) return 'Minimum 30 characters required';
        return null;
      },
    );
  }

  Widget _buildCreditField() {
    return TextFormField(
      controller: _creditController,
      decoration: const InputDecoration(
        labelText: 'Credits (1-10)',
        prefixIcon: Icon(Icons.credit_score),
        border: OutlineInputBorder(),
        helperText: '1 = Poor condition, 10 = Brand new',
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final credit = int.tryParse(value ?? '');
        return (credit == null || credit < 1 || credit > 10)
            ? 'Enter a value between 1 and 10'
            : null;
      },
    );
  }

  Widget _buildPriceField() {
    return TextFormField(
      controller: _priceController,
      decoration: const InputDecoration(
        labelText: 'Price रू',
        prefixIcon: Icon(Icons.currency_rupee),
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.done,
      validator: (value) {
        final price = double.tryParse(value ?? '');
        return (price == null || price < 0) ? 'Enter a valid price' : null;
      },
      // onChanged: (value) {
      //   if (value.isNotEmpty) {
      //     final formatted = NumberFormat.currency(
      //       decimalDigits: 2,
      //       symbol: '',
      //     ).format(double.tryParse(value) ?? value);
      //     _priceController.value = TextEditingValue(
      //       text: formatted,
      //       selection: TextSelection.collapsed(offset: formatted.length),
      //     );
      //   }
      // },
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Cover Image',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _isSubmitting ? null : _pickImage,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasAttemptedSubmit && _imageFile == null
                    ? Colors.red
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: _imageFile == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload book cover',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        if (_hasAttemptedSubmit && _imageFile == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Book cover is required',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _isSubmitting ? null : _submitForm,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Theme.of(context).primaryColor,
        disabledBackgroundColor: Colors.grey.shade300,
      ),
      icon: _isSubmitting
          ? const SizedBox.shrink()
          : const Icon(Icons.upload, color: Colors.white),
      label: _isSubmitting
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text(
              'PUBLISH BOOK',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
