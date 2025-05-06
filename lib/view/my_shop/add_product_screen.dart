import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/controllers/my_shope_controller/add_product_controller.dart';
import 'package:poketstore/controllers/shop_of_user_controller/shop_of_user_controller.dart';
import 'package:poketstore/model/shop_of_user_model/shop_of_user_model.dart';
import 'package:poketstore/view/my_shop/widget/category_dialog_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Make sure you have the necessary imports above...

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
  final TextEditingController _categoryController = TextEditingController();

  String? _selectedType;
  String? _selectedDeliveryOption;
  String? _selectedAvailability;
  List<String> _selectedCategories = [];
  String? _selectedShopId;

  final List<String> _typeOptions = ["Per Pack", "Per Unit", "Per KG"];
  final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  final List<String> _availabilityOptions = ["Available", "Out of Stock"];

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
    await provider.createProduct(
      shop: _selectedShopId.toString(),
      userId: _selectedShopId!,
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

  void _selectCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    List<String>? result = await showDialog(
      context: context,
      builder: (context) {
        return CategorySelectionDialog(
          categories: categoryProvider.categories,
          selectedCategories: _selectedCategories,
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedCategories = result;
        _categoryController.text = _selectedCategories.join(", ");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final shopProvider = Provider.of<ShopOfUserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
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
                    "Add Product",
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
                    _buildTextField("Product Name", _nameController),
                    _buildDropdownField(
                      "Select Type",
                      _selectedType,
                      _typeOptions,
                      (value) => setState(() => _selectedType = value),
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
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
                      (value) =>
                          setState(() => _selectedDeliveryOption = value),
                    ),
                    _buildTextField(
                      "Estimated Delivery Time (Days)",
                      _estimatedTimeController,
                    ),
                    _buildDropdownField(
                      "Availability Status",
                      _selectedAvailability,
                      _availabilityOptions,
                      (value) => setState(() => _selectedAvailability = value),
                    ),
                    _buildImagePicker(),
                    const SizedBox(height: 10),
                    productProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Padding(
                          padding: const EdgeInsets.all(15),
                          child: GestureDetector(
                            onTap: () => _submitProduct(context),
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
          border: const OutlineInputBorder(),
        ),
        validator:
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
        decoration: const InputDecoration(border: OutlineInputBorder()),
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
        decoration: const InputDecoration(border: OutlineInputBorder()),
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

  Widget _buildImagePicker() {
    return Column(
      children: [
        _selectedImage != null
            ? Image.file(
              _selectedImage!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
            : const SizedBox(),
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
              icon: const Icon(Icons.photo_library),
              label: const Text("Gallery"),
            ),
          ],
        ),
      ],
    );
  }
}
