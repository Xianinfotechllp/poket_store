import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart'; // Import CategoryController
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddShop extends StatefulWidget {
  final ShopModel? shopToEdit;
  const AddShop({super.key, this.shopToEdit});

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  // Removed _categoryController
  final TextEditingController _localityController = TextEditingController();
  final List<String> sellerTypes = ["Producer", "Trader"];
  final List<String> states = [
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
  ];
  List<String> _selectedCategories = [];
  String? _selectedSellerType;
  String? _selectedState;
  String? _selectedCategory; // To hold the selected category from the dropdown
  File? _headerImage;
  bool get _isEditing => widget.shopToEdit != null;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryController>(context, listen: false).loadCategories();
    _populateFields();
  }

  void _populateFields() {
    if (_isEditing) {
      final shop = widget.shopToEdit!;
      _shopNameController.text = shop.shopName;
      // _placeController.text = shop.place ?? ''; // Handle nullable place
      _pinCodeController.text = shop.pinCode;
      // _localityController.text = shop.locality ?? ''; // Handle nullable locality
      _selectedSellerType = shop.sellerType;
      _selectedState = shop.state;

      // Assuming 'category' is a List<String> and you want the first one for the dropdown
      if (shop.category.isNotEmpty) {
        _selectedCategory = shop.category.first;
      }
      _existingImageUrl = shop.headerImage; // Store existing image URL

      log("✏️ Populating fields for shop: ${shop.shopName}");
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          '${pickedFile.path}_compressed.jpg',
          quality: 70,
        );
        if (compressedFile != null) {
          setState(() {
            _headerImage = File(compressedFile.path);
          });
        }
      }
    } catch (e) {
      _showSnackbar("Image selection failed: $e");
    }
  }

  void _submitShop() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackbar("Please fill all required fields.");
      return;
    }

    // Validate image presence only for add mode, or if no new image selected in edit mode
    if (!_isEditing && _headerImage == null) {
      _showSnackbar("Please select a shop image.");
      return;
    }
    // In edit mode, if no new image is selected AND no existing image, then it's an error.
    if (_isEditing &&
        _headerImage == null &&
        (_existingImageUrl == null || _existingImageUrl!.isEmpty)) {
      _showSnackbar("Please select or retain a shop image.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      _showSnackbar("User ID not found. Please login again.");
      return;
    }

    final List<String> categoriesList =
        _selectedCategory != null ? [_selectedCategory!] : <String>[];

    final shopData = ShopModel(
      id: _isEditing ? widget.shopToEdit!.id : null, // Pass ID for update
      shopName: _shopNameController.text.trim(),
      category: categoriesList,
      sellerType: _selectedSellerType!,
      state: _selectedState!,
      // place: _placeController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      // locality: _localityController.text.trim(),
      headerImage: _existingImageUrl ?? "", // Use existing URL if no new image
      userId: userId, // Assuming userId is the salesmanId
      // Default values for new shop, will be overwritten by backend on update
      // active: true,
      // pendingOrders: 0,
      // totalOrders: 0,
      // totalSales: 0,
    );

    final provider = Provider.of<ShopProvider>(context, listen: false);

    if (_isEditing) {
      log("🔄 Attempting to update shop: ${shopData.shopName}");
      // Pass the image file (if new) to the updateShop method
      await provider.updateShopDetails(
        shopData,
      );
      if (provider.errorMessage.isNotEmpty) {
        _showSnackbar("Update failed: ${provider.errorMessage}");
      } else {
        _showSnackbar("Shop updated successfully!");
        Navigator.of(context).pop(true); // Pop back to details screen
      }
    } else {
      log("➕ Attempting to add new shop: ${shopData.shopName}");
      await provider.addShop(shopData, _headerImage);
      if (provider.errorMessage.isNotEmpty) {
        _showSnackbar("Registration failed: ${provider.errorMessage}");
      } else {
        _showSnackbar("Shop registered successfully!");
        Navigator.of(context).pop(true); // Pop back after adding
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title:
              Text(_isEditing ? "Edit Shop" : "Add New Shop"), // Dynamic title
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Consumer<ShopProvider>(
          builder: (context, shopProvider, child) {
            return Consumer<CategoryController>(
              builder: (context, categoryController, _) {
                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Remove the fixed header image for flexibility,
                        // keeping it dynamic for potential image selection.
                        const SizedBox(height: 16),
                        buildLabel("Shop Name"),
                        buildTextField(_shopNameController, "Enter shop name"),
                        buildLabel("Category"),
                        categoryController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : buildDropdown<String>(
                                "Select Category",
                                _selectedCategory,
                                categoryController.categoryList,
                                (String? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                              ),
                        buildLabel("Seller Type"),
                        buildDropdown(
                          "Select seller type",
                          _selectedSellerType,
                          sellerTypes,
                          (value) {
                            setState(() => _selectedSellerType = value);
                          },
                        ),
                        buildLabel("State"),
                        buildDropdown("Select state", _selectedState, states, (
                          value,
                        ) {
                          setState(() => _selectedState = value);
                        }),
                        buildLabel("District"),
                        buildTextField(_localityController, "Enter District"),
                        buildLabel("Place"),
                        buildTextField(_placeController, "Enter Place"),
                        buildLabel("Pin Code"),
                        buildTextField(
                          _pinCodeController,
                          "Enter pin code",
                          isNumeric: true,
                        ),
                        buildLabel("Shop Image"),
                        Center(
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: _headerImage != null
                                ? Image.file(
                                    _headerImage!,
                                    height: 150,
                                    fit: BoxFit.cover,
                                  )
                                : (_existingImageUrl != null &&
                                        _existingImageUrl!.isNotEmpty)
                                    ? Image.network(
                                        _existingImageUrl!,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          height: 150,
                                          width: double.infinity,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.image_not_supported,
                                                    size: 40),
                                                Text(
                                                    "Image failed to load. Tap to upload new."),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 150,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Text("Upload Shop Image"),
                                        ),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationPickerScreen(),
                                ),
                              );

                              if (result != null &&
                                  result is Map<String, String>) {
                                setState(() {
                                  _placeController.text = result['place'] ?? '';
                                  _pinCodeController.text =
                                      result['pincode'] ?? '';
                                  _localityController.text =
                                      result['subLocality'] ?? '';
                                  _selectedState = result['state'] ??
                                      _selectedState; // Update state from map
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Pick Location on Map"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: shopProvider.isLoading
                                  ? null
                                  : _submitShop, // Call the common submit method
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFF094497),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: shopProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _isEditing
                                          ? "Update Shop"
                                          : "Register Shop",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Reusable Widgets
Widget buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );
}

Widget buildTextField(
  TextEditingController controller,
  String hintText, {
  bool isNumeric = false,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}

Widget buildDropdown<T>(
  String hint,
  T? selectedValue,
  List<T> items,
  void Function(T?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: DropdownButtonFormField<T>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: Text(hint),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(item.toString())),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select an option" : null,
    ),
  );
}
