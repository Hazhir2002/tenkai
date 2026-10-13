import 'package:flutter/material.dart';
import 'package:tenkai/core/tokens/tenkai_spacing.dart';
import 'package:tenkai/features/knowledge/widgets/book_form.dart';

class BookFormScreen extends StatelessWidget {
  const BookFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New book')),
      body: SafeArea(
        minimum: EdgeInsets.all(TenkaiSpacing.md),
        child: BookForm(),
      ),
    );
  }
}
