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
  // New controllers for the new fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _landlineNumberController =
      TextEditingController();

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
        _shopNameController.text = shop.shopName ?? '';
        _placeController.text = shop.place ?? '';
        _pinCodeController.text = shop.pinCode ?? '';
        _localityController.text = shop.locality ?? '';
        _selectedSellerType = shop.sellerType;
        _selectedState = shop.state;
        if (shop.category!.isNotEmpty) {
          _selectedCategory = shop.category?.first;
        }
        _existingHeaderImageUrl = shop.headerImage;
        // Populate new fields when editing
        _emailController.text = shop.email ?? '';
        _mobileNumberController.text = shop.mobileNumber ?? '';
        _landlineNumberController.text = shop.landlineNumber ?? '';
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _placeController.dispose();
    _pinCodeController.dispose();
    _localityController.dispose();
    // Dispose new controllers
    _emailController.dispose();
    _mobileNumberController.dispose();
    _landlineNumberController.dispose();
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
                null; // Clear existing image if new one is picked
          });
        }
      }
    } catch (e) {
      _showSnackbar("Image selection failed: $e", isError: true);
    }
  }

  void _submitShop() async {
    if (!_formKey.currentState!.validate() ||
        _selectedCategory == null ||
        _selectedSellerType == null ||
        _selectedState == null) {
      _showSnackbar(
        "Please fill all required fields and select an image, category, type, and state.",
        isError: true,
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null || userId.isEmpty) {
      _showSnackbar("User ID not found. Please login again.", isError: true);
      return;
    }

    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    if (isEditing) {
      final updatedShopDetails = ShopeDetailsModel(
        id: widget.shopToEdit!.id,
        shopName: _shopNameController.text.trim(),
        category: [_selectedCategory!],
        sellerType: _selectedSellerType!,
        state: _selectedState!,
        place:
            _placeController.text.trim().isEmpty
                ? null
                : _placeController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        locality:
            _localityController.text.trim().isEmpty
                ? null
                : _localityController.text.trim(),
        headerImage:
            _existingHeaderImageUrl ?? '', // Use existing if no new image
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        mobileNumber:
            _mobileNumberController.text.trim().isEmpty
                ? null
                : _mobileNumberController.text.trim(),
        landlineNumber:
            _landlineNumberController.text.trim().isEmpty
                ? null
                : _landlineNumberController.text.trim(),
      );
      await shopProvider.updateShop(
        updatedShopDetails,
      ); // Pass new image for update
    } else {
      final newShop = ShopModel(
        shopName: _shopNameController.text.trim(),
        category: [_selectedCategory!],
        sellerType: _selectedSellerType!,
        state: _selectedState!,
        place:
            _placeController.text.trim().isEmpty
                ? null
                : _placeController.text.trim(),
        pinCode: _pinCodeController.text.trim(),
        locality:
            _localityController.text.trim().isEmpty
                ? null
                : _localityController.text.trim(),
        headerImage: "", // Will be updated by the server
        userId: userId,
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        mobileNumber:
            _mobileNumberController.text.trim().isEmpty
                ? null
                : _mobileNumberController.text.trim(),
        landlineNumber:
            _landlineNumberController.text.trim().isEmpty
                ? null
                : _landlineNumberController.text.trim(),
      );
      await shopProvider.addShop(newShop, _headerImage);
    }

    if (shopProvider.errorMessage.isNotEmpty) {
      _showSnackbar(shopProvider.errorMessage, isError: true);
    } else {
      _showSnackbar(
        isEditing
            ? "Shop updated successfully!"
            : "Shop registered successfully!",
      );
      // Refresh relevant data
      Provider.of<HomeProductController>(context, listen: false).loadProducts();
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
      Provider.of<ShopOfUserProvider>(context, listen: false).fetchUserShops();
      Navigator.of(context).pop(true); // Pop with true to indicate success
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red : const Color.fromARGB(255, 7, 3, 201),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: const Color.fromARGB(255, 7, 3, 201),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            title: Text(
              isEditing ? "Edit Shop" : "Add Shop",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Shop Name"),
                        _buildTextField(_shopNameController, "Enter shop name"),
                        _buildLabel("Category"),
                        categoryController.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildDropdown<String>(
                              "Select Category",
                              _selectedCategory,
                              categoryController.categoryList,
                              (value) =>
                                  setState(() => _selectedCategory = value),
                            ),
                        _buildLabel("Seller Type"),
                        _buildDropdown(
                          "Select seller type",
                          _selectedSellerType,
                          sellerTypes,
                          (value) =>
                              setState(() => _selectedSellerType = value),
                        ),
                        _buildLabel("State"),
                        _buildDropdown(
                          "Select state",
                          _selectedState,
                          states,
                          (value) => setState(() => _selectedState = value),
                        ),
                        _buildLabel("District"),
                        _buildTextField(_localityController, "Enter District"),
                        _buildLabel("Place"),
                        _buildTextField(_placeController, "Enter Place"),
                        _buildLabel("Pin Code"),
                        _buildTextField(
                          _pinCodeController,
                          "Enter pin code",
                          isNumeric: true,
                        ),
                        // New fields
                        _buildLabel("Email"),
                        _buildTextField(
                          _emailController,
                          "Enter email address",
                          isEmail: true,
                        ),
                        _buildLabel("Mobile Number"),
                        _buildTextField(
                          _mobileNumberController,
                          "Enter mobile number",
                          isNumeric: true,
                        ),
                        _buildLabel("Landline Number (Optional)"),
                        _buildTextField(
                          _landlineNumberController,
                          "Enter landline number",
                          isNumeric: true,
                          isOptional: true, // Mark as optional
                        ),

                        const SizedBox(height: 20),
                        _buildLabel("Shop Image"),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 4,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(
                                      Icons.upload_file,
                                      color: Color.fromARGB(255, 7, 3, 201),
                                    ),
                                    label: const Text(
                                      "Choose File",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 7, 3, 201),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(
                                          color: Color.fromARGB(255, 7, 3, 201),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  if (_headerImage == null &&
                                      _existingHeaderImageUrl != null &&
                                      _existingHeaderImageUrl!.isNotEmpty)
                                    const Text(
                                      "Existing image selected",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              if (_headerImage != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _headerImage!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              else if (_existingHeaderImageUrl != null &&
                                  _existingHeaderImageUrl!.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    _existingHeaderImageUrl!,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey.shade300,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                  ),
                                )
                              else
                                Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "No image selected",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
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
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.location_on),
                          label: const Text(
                            "Pick Location on Map",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                shopProvider.isLoading ? null : _submitShop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0XFF094497),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                shopProvider.isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      isEditing
                                          ? "Update Shop"
                                          : "Register Shop",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20), // Add some bottom padding
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

  // --- Reusable Widgets (made private to this class) ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText, {
    bool isNumeric = false,
    bool isEmail = false,
    bool isOptional = false, // New parameter for optional fields
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isNumeric
                ? TextInputType.number
                : (isEmail ? TextInputType.emailAddress : TextInputType.text),
        validator: (value) {
          if (!isOptional && (value == null || value.isEmpty)) {
            return "This field is required";
          }
          if (isNumeric && value!.isNotEmpty && int.tryParse(value) == null) {
            return "Please enter a valid number";
          }
          if (isEmail &&
              value!.isNotEmpty &&
              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return "Please enter a valid email";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), // More rounded corners
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }

  Widget _buildDropdown<T>(
    String hint,
    T? selectedValue,
    List<T> items,
    void Function(T?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<T>(
        value: selectedValue,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
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
        hint: Text(hint),
        items:
            items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(item.toString()),
                  ),
                )
                .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select an option" : null,
      ),
    );
  }
}
