import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _estimatedTimeController =
      TextEditingController();

  String? _selectedType;
  String? _selectedDeliveryOption;
  String? _selectedAvailability;
  List<String> _selectedCategories = [];

  final List<String> _typeOptions = ["Per Pack", "Per Unit", "Per KG"];
  final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  final List<String> _availabilityOptions = ["Available", "Out of Stock"];
  final List<String> _categoryOptions = [
    "Electronics",
    "Clothing",
    "Grocery",
    "Home & Kitchen",
    "Beauty",
  ];

  Future<void> _pickImage(ImageSource source) async {
    var status = await Permission.photos.request();
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Permission denied!")));
    }
  }

  Future<void> _submitProduct() async {
    if (!_formKey.currentState!.validate() ||
        _selectedImage == null ||
        _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields, select an image, and choose at least one category.",
          ),
        ),
      );
      return;
    }
    log("Product Name: ${_nameController.text.trim()}");
    log("Description: ${_descriptionController.text.trim()}");
    log("Price: ${_priceController.text.trim()}");
    log("Quantity: ${_quantityController.text.trim()}");
    log("Categories: $_selectedCategories");
    log("Estimated Time: ${_estimatedTimeController.text.trim()}");
    log("Product Type: $_selectedType");
    log("Delivery Option: $_selectedDeliveryOption");
    log("Image Path: ${_selectedImage!.path}");
    final provider = Provider.of<ProductProvider>(context, listen: false);
    await provider.createProduct(
      productImage: _selectedImage!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      quantity: int.parse(_quantityController.text.trim()),
      category: _selectedCategories,
      estimatedTime: _estimatedTimeController.text.trim(),
      productType: _selectedType!,
      deliveryOption: _selectedDeliveryOption!,
    );

    if (provider.product != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add product!")));
    }
  }

  Future<void> _selectCategories() async {
    await showDialog(
      context: context,
      builder: (context) {
        return MultiSelectDialog(
          items:
              _categoryOptions
                  .map(
                    (category) => MultiSelectItem<String>(category, category),
                  )
                  .toList(),
          initialValue: _selectedCategories,
          onConfirm: (values) {
            setState(() {
              _selectedCategories = values.cast<String>();
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(title: const Text("Add Product")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage('assets/myshope.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 130,
                  child: Text(
                    "My Shop",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField("Product Name", _nameController),
                    _buildDropdownField(
                      "Select Type",
                      _selectedType,
                      _typeOptions,
                      (value) {
                        setState(() => _selectedType = value);
                      },
                    ),
                    _buildTextField("Price", _priceController, isNumber: true),
                    _buildTextField(
                      "Stock Quantity",
                      _quantityController,
                      isNumber: true,
                    ),
                    _buildTextField("Description", _descriptionController),

                    GestureDetector(
                      onTap: _selectCategories,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: "Select Categories",
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                            text:
                                _selectedCategories.isNotEmpty
                                    ? _selectedCategories.join(", ")
                                    : null,
                          ),
                          validator:
                              (value) =>
                                  _selectedCategories.isEmpty
                                      ? "Please select at least one category"
                                      : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    _buildDropdownField(
                      "Delivery Option",
                      _selectedDeliveryOption,
                      _deliveryOptions,
                      (value) {
                        setState(() => _selectedDeliveryOption = value);
                      },
                    ),
                    _buildTextField(
                      "Estimated Delivery Time (Days)",
                      _estimatedTimeController,
                    ),
                    _buildDropdownField(
                      "Availability Status",
                      _selectedAvailability,
                      _availabilityOptions,
                      (value) {
                        setState(() => _selectedAvailability = value);
                      },
                    ),
                    _buildImagePicker(),
                    const SizedBox(height: 10),
                    provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.all(15),
                          child: GestureDetector(
                            onTap: () {
                              _submitProduct();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 7, 3, 201),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 50,
                              width: double.infinity,
                              child: const Center(
                                child: Text(
                                  'Save',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator:
            (value) =>
                value == null || value.isEmpty ? "$label is required" : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: OutlineInputBorder()),
        value: selectedValue,
        hint: Text("Select $label"),
        items:
            options
                .map(
                  (option) =>
                      DropdownMenuItem(value: option, child: Text(option)),
                )
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Product Image"),
          const SizedBox(height: 10),
          _selectedImage != null
              ? Image.file(
                _selectedImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              )
              : Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(child: Text("No Image Selected")),
              ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text("Gallery"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
