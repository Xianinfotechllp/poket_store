// AddShop.dart
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/model/my_shope_model/shope_details_model.dart';
import 'package:poketstore/view/location.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/home_product_controller/home_product_controller.dart';
import '../../controllers/shop_of_user_controller/shop_of_user_controller.dart';

class AddShop extends StatefulWidget {
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
    "West Bengal"
  ];

  String? _selectedSellerType;
  String? _selectedState;
  String? _selectedCategory;
  File? _headerImage;
  String? _existingHeaderImageUrl;

  bool get isEditing => widget.shopToEdit != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryController>(context, listen: false).loadCategories();
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
        _existingHeaderImageUrl = shop.headerImage;
      }
    });
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
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          pickedFile.path,
          '${pickedFile.path}_compressed.jpg',
          quality: 70,
        );
        if (compressedFile != null) {
          setState(() {
            _headerImage = File(compressedFile.path);
            _existingHeaderImageUrl = null;
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
          "Please fill all required fields and select image, category, type and state.");
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
        headerImage: _existingHeaderImageUrl ?? '',
      );
      await provider.updateShop(updatedShopDetails);
    } else {
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
        headerImage: "",
        userId: userId,
      );
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
      Navigator.of(context).pop(true);
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Color.fromARGB(255, 7, 3, 201),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            title: Text(
              isEditing ? "Edit Shop" : "Add Shop",
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
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
                                (value) =>
                                    setState(() => _selectedCategory = value),
                              ),
                        buildLabel("Seller Type"),
                        buildDropdown(
                          "Select seller type",
                          _selectedSellerType,
                          sellerTypes,
                          (value) =>
                              setState(() => _selectedSellerType = value),
                        ),
                        buildLabel("State"),
                        buildDropdown(
                          "Select state",
                          _selectedState,
                          states,
                          (value) => setState(() => _selectedState = value),
                        ),
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
                        const SizedBox(height: 12),
                        buildLabel("Shop Image"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text("Choose File"),
                                  ),
                                  const SizedBox(width: 10),
                                  if (_headerImage == null &&
                                      _existingHeaderImageUrl != null &&
                                      _existingHeaderImageUrl!.isNotEmpty)
                                    const Text("Existing image selected"),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_headerImage != null)
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Image.file(_headerImage!,
                                      fit: BoxFit.cover),
                                )
                              else if (_existingHeaderImageUrl != null &&
                                  _existingHeaderImageUrl!.isNotEmpty)
                                SizedBox(
                                  height: 100,
                                  width: 100,
                                  child: Image.network(_existingHeaderImageUrl!,
                                      fit: BoxFit.cover),
                                ),
                            ],
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
                                  _selectedState =
                                      result['state'] ?? _selectedState;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
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

// ------------------ Reusable Widgets ------------------

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
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(item.toString()),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select an option" : null,
    ),
  );
}
