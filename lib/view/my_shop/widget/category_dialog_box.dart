import 'package:flutter/material.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/model/category_model/category_model.dart';

class CategorySelectionDialog extends StatefulWidget {
  final List<Category> categories;
  final List<String> selectedCategories;

  const CategorySelectionDialog({
    required this.categories,
    required this.selectedCategories,
  });

  @override
  _CategorySelectionDialogState createState() =>
      _CategorySelectionDialogState();
}

class _CategorySelectionDialogState extends State<CategorySelectionDialog> {
  late List<String> tempSelected;
  final TextEditingController _categoryController = TextEditingController();
  List<Category> updatedCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedCategories);
    updatedCategories = List.from(widget.categories);
  }

  void _addCategory() async {
    final provider = Provider.of<CategoryProvider>(context, listen: false);
    String name = _categoryController.text.trim();

    if (name.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      try {
        await provider.addCategory(name);
        _categoryController.clear();

        // Fetch updated categories and refresh UI
        setState(() {
          updatedCategories = List.from(provider.categories);
          _isLoading = false;
        });

        // Close the dialog and reopen it to refresh completely
        Navigator.pop(context);
        showDialog(
          context: context,
          builder:
              (context) => CategorySelectionDialog(
                categories: updatedCategories,
                selectedCategories: tempSelected,
              ),
        );

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Category added successfully')));
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add category: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Category name cannot be empty')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Categories"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else
              ...updatedCategories.map((category) {
                return CheckboxListTile(
                  title: Text(category.name),
                  value: tempSelected.contains(category.name),
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        tempSelected.add(category.name);
                      } else {
                        tempSelected.remove(category.name);
                      }
                    });
                  },
                );
              }).toList(),
            const SizedBox(height: 10),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Add New Category",
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, tempSelected);
          },
          child: Text("OK"),
        ),
      ],
    );
  }
}
