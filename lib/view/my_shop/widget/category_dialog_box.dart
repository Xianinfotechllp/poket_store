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

  @override
  void initState() {
    super.initState();
    tempSelected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select Categories"),
      content: SingleChildScrollView(
        child: Column(
          children:
              widget.categories.map((category) {
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
