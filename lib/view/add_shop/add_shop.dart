import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:poketstore/controllers/add_shop_controller/add_shop_controller.dart';
import 'package:poketstore/controllers/category_controller/category_controller.dart';
import 'package:poketstore/model/add_shope_model/add_shop_model.dart';
import 'package:poketstore/view/my_shop/widget/category_dialog_box.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class AddShop extends StatefulWidget {
  const AddShop({super.key});

  @override
  State<AddShop> createState() => _AddShopState();
}

class _AddShopState extends State<AddShop> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _pinCodeController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  List<String> _selectedCategories = [];
  String? _selectedSellerType;
  String? _selectedState;
  File? _headerImage;

  // final List<String> categories = [
  //   "Grocery",
  //   "Electronics",
  //   "Clothing",
  //   "Furniture",
  // ];
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

  void _registerShop() async {
    if (!_formKey.currentState!.validate() ||
        _headerImage == null ||
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

    // Get userId from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      _showSnackbar("User ID not found. Please login again.");
      return;
    }

    // Log the data before submitting
    log("Registering shop with details:");
    log("Shop Name: ${_shopNameController.text.trim()}");
    log("Categories: $_selectedCategories");
    log("Seller Type: $_selectedSellerType");
    log("State: $_selectedState");
    log("Place: ${_placeController.text.trim()}");
    log("Pin Code: ${_pinCodeController.text.trim()}");
    log("Header Image Path: ${_headerImage!.path}");
    log("User ID: $userId");

    final shop = ShopModel(
      shopName: _shopNameController.text.trim(),
      category: _selectedCategories,
      sellerType: _selectedSellerType!,
      state: _selectedState!,
      place: _placeController.text.trim(),
      pinCode: _pinCodeController.text.trim(),
      headerImage: "", // The image file will be passed separately
      userId: userId,
    );

    final provider = Provider.of<ShopProvider>(context, listen: false);
    await provider.addShop(shop, _headerImage);

    if (provider.errorMessage.isNotEmpty) {
      _showSnackbar(provider.errorMessage);
    } else {
      _showSnackbar("Shop registered successfully!");
      Navigator.of(context).pop(true); // Go back to previous screen
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectCategories() async {
    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );

    // Show category selection dialog
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
    // Fetch categories when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ShopProvider>(
          builder: (context, provider, child) {
            return Stack(
              children: [
                SingleChildScrollView(
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
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/image.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 80,
                              left: 80,
                              child: Text(
                                "Register Your Shop",
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
                        const SizedBox(height: 16),

                        buildLabel("Shop Name"),
                        buildTextField(_shopNameController, "Enter shop name"),

                        buildLabel("Category"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: GestureDetector(
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

                        buildLabel("Place"),
                        buildTextField(_placeController, "Enter place"),

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
                            child:
                                _headerImage != null
                                    ? Image.file(
                                      _headerImage!,
                                      height: 150,
                                      fit: BoxFit.cover,
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
                          padding: const EdgeInsets.all(10),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  provider.isLoading ? null : _registerShop,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFF094497),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child:
                                  provider.isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        "Register",
                                        style: TextStyle(
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
                ),
              ],
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

Widget buildDropdown(
  String hint,
  String? selectedValue,
  List<String> items,
  void Function(String?) onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      hint: Text(hint),
      items:
          items
              .map(
                (item) =>
                    DropdownMenuItem<String>(value: item, child: Text(item)),
              )
              .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select an option" : null,
    ),
  );
}
