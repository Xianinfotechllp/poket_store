import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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

  String? _selectedCategory;
  String? _selectedSellerType;
  String? _selectedState;
  File? _headerImage;

  final List<String> categories = [
    "Grocery",
    "Electronics",
    "Clothing",
    "Furniture",
  ];
  final List<String> sellerTypes = ["Producer", "Trader"];
  final List<String> states = [
    "Kerala",
    "Tamil Nadu",
    "Karnataka",
    "Maharashtra",
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

  void _registerShop() {
    if (!_formKey.currentState!.validate()) return;

    if (_headerImage == null) {
      _showSnackbar("Please upload a shop image.");
      return;
    }

    _showSnackbar("Shop registered successfully!");
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
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Image with Overlay Text
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

                // Shop Name
                buildLabel("Shop Name"),
                buildTextField(_shopNameController, "Enter shop name"),

                // Category Dropdown
                buildLabel("Category"),
                buildDropdown(
                  "Select category",
                  _selectedCategory,
                  categories,
                  (value) {
                    setState(() => _selectedCategory = value);
                  },
                ),

                // Seller Type Dropdown
                buildLabel("Seller Type"),
                buildDropdown(
                  "Select seller type",
                  _selectedSellerType,
                  sellerTypes,
                  (value) {
                    setState(() => _selectedSellerType = value);
                  },
                ),

                // State Dropdown
                buildLabel("State"),
                buildDropdown("Select state", _selectedState, states, (value) {
                  setState(() => _selectedState = value);
                }),

                // Place
                buildLabel("Place"),
                buildTextField(_placeController, "Enter place"),

                // Pin Code
                buildLabel("Pin Code"),
                buildTextField(
                  _pinCodeController,
                  "Enter pin code",
                  isNumeric: true,
                ),

                // Shop Image Picker
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
                                child: Text("Upload Header Image"),
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),

                // Register Button
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerShop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF094497),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          items.map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Please select an option" : null,
    ),
  );
}
