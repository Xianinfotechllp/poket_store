import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart'; // For adding new shop
import 'package:poketstore/model/my_shope_model/shope_details_model.dart'; // For editing existing shop
import 'package:poketstore/view/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_product_controller/home_product_controller.dart';
import '../../controllers/shop_of_user_controller/shop_of_user_controller.dart';

class AddShop extends StatefulWidget {
  // Now accepts ShopeDetailsModel for editing
  final ShopeDetailsModel? shopToEdit;

  const AddShop({super.key, this.shopToEdit});

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
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

  String? _selectedSellerType;
  String? _selectedState;
  String? _selectedCategory;
  File? _headerImage; // For newly picked image
  String? _existingHeaderImageUrl; // For displaying existing image URL

  bool get isEditing => widget.shopToEdit != null;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoryController>(context, listen: false).loadCategories();

    // Pre-populate fields if editing an existing shop
    if (isEditing) {
      final shop = widget.shopToEdit!;
      _shopNameController.text = shop.shopName;
      _placeController.text = shop.place ?? '';
      _pinCodeController.text = shop.pinCode;
      _localityController.text = shop.locality ?? '';
      _selectedSellerType = shop.sellerType;
      _selectedState = shop.state;
      if (shop.category.isNotEmpty) {
        _selectedCategory = shop.category.first;
      }
      _existingHeaderImageUrl = shop.headerImage; // Set existing image URL
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _placeController.dispose();
    _pinCodeController.dispose();
    _localityController.dispose();
    super.dispose();
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
            _existingHeaderImageUrl =
                null; // Clear existing URL if new image is picked
          });
        }
      }
    } catch (e) {
      _showSnackbar("Image selection failed: $e");
    }
  }

  void _submitShop() async {
    if (!_formKey.currentState!.validate() ||
        (_headerImage == null && _existingHeaderImageUrl == null) ||
        _selectedCategory == null ||
        _selectedSellerType == null ||
        _selectedState == null) {
      _showSnackbar(
          "Please fill all required fields, select an image, and choose a category, seller type, and state.");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      _showSnackbar("User ID not found. Please login again.");
      return;
    }

    final provider = Provider.of<ShopProvider>(context, listen: false);

    if (isEditing) {
      log("Updating shop with details:");
      final updatedShopDetails = ShopeDetailsModel(
        id: widget.shopToEdit!.id,
        shopName: _shopNameController.text.trim(),
        category: [_selectedCategory!],
        sellerType: _selectedSellerType!,
        state: _selectedState!,
        place: _placeController.text.trim().isEmpty
            ? null
            : _placeController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        locality: _localityController.text.trim().isEmpty
            ? null
            : _localityController.text.trim(),
        headerImage: _existingHeaderImageUrl ??
            '', // This will be the old URL if no new image, or empty
        // userId: userId, // Pass userId for update
        // active: widget.shopToEdit!.active, // Retain existing values for these
        // pendingOrders: widget.shopToEdit!.pendingOrders,
        // totalOrders: widget.shopToEdit!.totalOrders,
        // totalSales: widget.shopToEdit!.totalSales,
      );

      await provider.updateShop(
        updatedShopDetails,
      );
    } else {
      log("Registering shop with details:");
      final newShop = ShopModel(
        shopName: _shopNameController.text.trim(),
        category: [_selectedCategory!],
        sellerType: _selectedSellerType!,
        state: _selectedState!,
        place: _placeController.text.trim().isEmpty
            ? null
            : _placeController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        locality: _localityController.text.trim().isEmpty
            ? null
            : _localityController.text.trim(),
        headerImage: "", // Will be set by backend upon upload
        userId: userId,
      );
      // Log the newShop object before adding it
      log("New Shop Data: ${newShop.toJson()}");
      await provider.addShop(newShop, _headerImage);
    }

    if (provider.errorMessage.isNotEmpty) {
      _showSnackbar(provider.errorMessage);
    } else {
      _showSnackbar(isEditing
          ? "Shop updated successfully!"
          : "Shop registered successfully!");
      Provider.of<HomeProductController>(context, listen: false).loadProducts();
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();

      Navigator.of(context)
          .pop(true); // Pop back to previous screen (details screen)
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? "Edit Shop" : "Add Shop"),
        ),
        backgroundColor: Colors.white,
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
                        Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: _headerImage != null
                                    ? DecorationImage(
                                        image: FileImage(_headerImage!),
                                        fit: BoxFit.cover,
                                      )
                                    : _existingHeaderImageUrl != null &&
                                            _existingHeaderImageUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(
                                                _existingHeaderImageUrl!),
                                            fit: BoxFit.cover,
                                            onError: (exception, stackTrace) =>
                                                const DecorationImage(
                                                    image: AssetImage(
                                                        'assets/image.png'),
                                                    fit: BoxFit
                                                        .cover), // Fallback to default asset
                                          )
                                        : const DecorationImage(
                                            image:
                                                AssetImage('assets/image.png'),
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            ),
                            Positioned(
                              bottom: 80,
                              left: 80,
                              child: Text(
                                isEditing
                                    ? "Edit Your Shop"
                                    : "Add Your Shop Image",
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
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _pickImage,
                                  child: Center(
                                    child: _headerImage == null &&
                                            (_existingHeaderImageUrl == null ||
                                                _existingHeaderImageUrl!
                                                    .isEmpty)
                                        ? const Icon(Icons.camera_alt,
                                            color: Colors.white70, size: 50)
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                        buildDropdown("Select state", _selectedState, states,
                            (value) {
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
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  shopProvider.isLoading ? null : _submitShop,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFF094497),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: shopProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      isEditing
                                          ? "Update Shop"
                                          : "Register Shop",
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 18),
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

// Reusable Widgets (kept as is)
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
