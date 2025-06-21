import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart'; // Import the CategoryController
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _selectedShopId;

  final List<String> _typeOptions = ["Per Pack", "Per Unit", "Per KG"];
  final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  final List<String> _availabilityOptions = ["Available", "Out of Stock"];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
      Provider.of<CategoryController>(
        context,
        listen: false,
      ).loadCategories(); // Load categories on initialization
    });
  }

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

  Future<void> _submitProduct(BuildContext context) async {
    final int? quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a valid stock quantity.")),
      );
      return;
    }

    if (!_formKey.currentState!.validate() ||
        _selectedImage == null ||
        _selectedCategories.isEmpty ||
        _selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields, select an image, choose at least one category, and select a shop.",
          ),
        ),
      );
      return;
    }

    final provider = Provider.of<ProductProvider>(context, listen: false);
    String categoryString = _selectedCategories.join(',');

    await provider.createProduct(
      shop: _selectedShopId.toString(),
      userId: _selectedShopId!,
      productImage: _selectedImage!,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      quantity: quantity,
      category: categoryString,
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

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final shopProvider = Provider.of<ShopOfUserProvider>(context);
    final categoryController = Provider.of<CategoryController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 7, 3, 201),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: const Text(
          "Add Product",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // The image background is already handled by the AppBar's shape/color,
            // so this Stack with the image might be redundant or could be
            // creatively used for a header if desired. For now, we'll keep
            // the AppBar and assume this Stack is for a visual header effect.
            // If the image is meant to be part of the form, it should be
            // moved down. Given the request for a back button on top,
            // the AppBar is the correct place for it.
            // Keeping the Stack as is for the visual banner effect as
            // it was in the original code, but adjusting the text.
            // Stack(
            //   children: [
            //     Container(
            //       height:
            //           150, // Slightly reduced height to make space for AppBar
            //       width: double.infinity,
            //       decoration: const BoxDecoration(
            //         image: DecorationImage(
            //           image: AssetImage('assets/myshope.png'),
            //           fit: BoxFit.cover,
            //         ),
            //       ),
            //     ),
            //     // Removed the "Add Product" text from here as it's now in the AppBar
            //   ],
            // ),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20), // Increased padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShopDropdownField(
                      "Select Shop",
                      _selectedShopId,
                      shopProvider.shopList.map((shop) => shop.id).toList(),
                      (value) {
                        setState(() => _selectedShopId = value);
                      },
                      Map.fromEntries(
                        shopProvider.shopList.map(
                          (shop) => MapEntry(shop.id, shop.shopName),
                        ),
                      ),
                    ),
                    _buildTextField(
                      "Product Name",
                      _nameController,
                      hintText: "e.g., Organic Apples",
                    ),
                    _buildDropdownField(
                      "Select Type",
                      _selectedType,
                      _typeOptions,
                      (value) => setState(() => _selectedType = value),
                    ),
                    _buildTextField(
                      "Price",
                      _priceController,
                      isNumber: true,
                      hintText: "e.g., 250",
                    ),
                    _buildTextField(
                      "Stock Quantity",
                      _quantityController,
                      isNumber: true,
                      hintText: "e.g., 100",
                    ),
                    _buildTextField(
                      "Description",
                      _descriptionController,
                      hintText: "Provide a detailed description of the product",
                    ),
                    categoryController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildCategoryDropdownField(
                          "Categories",
                          _selectedCategories,
                          categoryController
                              .categoryList, // Use the fetched categories
                          (values) {
                            setState(() {
                              _selectedCategories = values;
                            });
                          },
                        ),
                    const SizedBox(height: 15),
                    _buildDropdownField(
                      "Delivery Option",
                      _selectedDeliveryOption,
                      _deliveryOptions,
                      (value) =>
                          setState(() => _selectedDeliveryOption = value),
                    ),
                    _buildTextField(
                      "Estimated Delivery Time (Days)",
                      _estimatedTimeController,
                      hintText: "e.g., 3-4 business days",
                    ),
                    _buildDropdownField(
                      "Availability Status",
                      _selectedAvailability,
                      _availabilityOptions,
                      (value) => setState(() => _selectedAvailability = value),
                    ),
                    const SizedBox(height: 15),
                    _buildImagePicker(),
                    const SizedBox(height: 25), // Increased spacing
                    productProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : SizedBox(
                          width: double.infinity, // Make button full width
                          child: ElevatedButton(
                            onPressed: () => _submitProduct(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                7,
                                3,
                                201,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 5, // Add subtle shadow
                            ),
                            child: const Text(
                              'Add Product', // Changed text from 'Save' to 'Add Product' for clarity
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 20), // Spacing at the bottom
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
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ), // Highlight focused border
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator:
            validator ??
            (value) =>
                value == null || value.isEmpty ? 'Please enter $label' : null,
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
        decoration: InputDecoration(
          labelText: label, // Use labelText for consistency
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        value: selectedValue,
        hint: Text("Select $label"),
        items:
            options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  Widget _buildShopDropdownField(
    String label,
    String? selectedValue,
    List<String?> options,
    ValueChanged<String?> onChanged,
    Map<String, String> shopNameMap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        value: selectedValue,
        hint: Text("Select $label"),
        items:
            options
                .where((option) => option != null)
                .map<DropdownMenuItem<String>>((String? option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(shopNameMap[option] ?? 'Unknown Shop'),
                  );
                })
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }

  Widget _buildCategoryDropdownField(
    String label,
    List<String> selectedValues,
    List<String> options,
    ValueChanged<List<String>> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 7, 3, 201),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        child: DropdownButtonHideUnderline(
          // Hide the default underline
          child: DropdownButton<String>(
            isExpanded: true,
            value:
                null, // Set value to null to show hint always for multi-select
            hint: Text(
              selectedValues.isEmpty
                  ? "Select categories"
                  : selectedValues.join(', '),
            ), // Show selected categories or hint
            items:
                options.map((String value) {
                  final isSelected = selectedValues.contains(value);
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_box, color: Colors.blue)
                        else
                          const Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.grey,
                          ),
                        const SizedBox(width: 8),
                        Text(value),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                List<String> updatedList = List<String>.from(selectedValues);
                if (updatedList.contains(newValue)) {
                  updatedList.remove(newValue);
                } else {
                  updatedList.add(newValue);
                }
                onChanged(updatedList);
              }
            },
            selectedItemBuilder: (BuildContext context) {
              return options.map((String value) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedValues.isEmpty
                        ? "Select categories"
                        : selectedValues.join(', '),
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Image",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child:
                _selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                    : const Center(
                      child: Text(
                        "No image selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
