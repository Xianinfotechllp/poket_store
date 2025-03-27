import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _selectedImage;

  String? _selectedType;
  String? _selectedDeliveryOption;
  String? _selectedAvailability;

  // final List<String> _typeOptions = ["Per Pack", "Per Unit", "Per KG"];
  // final List<String> _deliveryOptions = ["Home Delivery", "Store Pickup"];
  // final List<String> _availabilityOptions = ["Available", "Out of Stock"];

  Future<void> _pickImage() async {
    var status = await Permission.photos.request(); // For iOS & Android 13+
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Permission denied!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
                      image: AssetImage('assets/addproduct.png'),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 80,
                  left: 120,
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
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Product Name'),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: "Product Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text('Select Type'),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(15),
            //   child: DropdownButtonFormField<String>(
            //     decoration: const InputDecoration(border: OutlineInputBorder()),
            //     value: _selectedType,
            //     hint: const Text("Select Type"),
            //     items:
            //         _typeOptions.map((type) {
            //           return DropdownMenuItem(value: type, child: Text(type));
            //         }).toList(),
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedType = value;
            //       });
            //     },
            //   ),
            // ),
            const Padding(padding: EdgeInsets.all(10), child: Text('Price')),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Price",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Stock Quantity'),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Stock Quantity",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text('Description'),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(10), child: Text('Category')),
            Padding(
              padding: const EdgeInsets.all(15),
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // const Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text('Delivery Option'),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(15),
            //   child: DropdownButtonFormField<String>(
            //     decoration: const InputDecoration(border: OutlineInputBorder()),
            //     value: _selectedDeliveryOption,
            //     hint: const Text("Select Delivery Option"),
            //     items:
            //         _deliveryOptions.map((option) {
            //           return DropdownMenuItem(
            //             value: option,
            //             child: Text(option),
            //           );
            //         }).toList(),
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedDeliveryOption = value;
            //       });
            //     },
            //   ),
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text('Estimate Delivery Time'),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(15),
            //   child: TextFormField(
            //     keyboardType: TextInputType.number,
            //     decoration: const InputDecoration(
            //       labelText: "Estimate Time (in days)",
            //       border: OutlineInputBorder(),
            //     ),
            //   ),
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text('Availability Status'),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(15),
            //   child: DropdownButtonFormField<String>(
            //     decoration: const InputDecoration(border: OutlineInputBorder()),
            //     value: _selectedAvailability,
            //     hint: const Text("Select Availability"),
            //     items:
            //         _availabilityOptions.map((status) {
            //           return DropdownMenuItem(
            //             value: status,
            //             child: Text(status),
            //           );
            //         }).toList(),
            //     onChanged: (value) {
            //       setState(() {
            //         _selectedAvailability = value;
            //       });
            //     },
            //   ),
            // ),
            // const Padding(
            //   padding: EdgeInsets.all(10),
            //   child: Text('Product Image'),
            // ),
            // Padding(
            //   padding: const EdgeInsets.all(15),
            //   child: Column(
            //     children: [
            //       _selectedImage != null
            //           ? Image.file(
            //             _selectedImage!,
            //             height: 150,
            //             width: double.infinity,
            //             fit: BoxFit.cover,
            //           )
            //           : Container(
            //             height: 150,
            //             width: double.infinity,
            //             decoration: BoxDecoration(
            //               border: Border.all(color: Colors.grey),
            //               borderRadius: BorderRadius.circular(10),
            //             ),
            //             child: const Center(child: Text("No Image Selected")),
            //           ),
            //       const SizedBox(height: 10),
            //       ElevatedButton.icon(
            //         onPressed: _pickImage,
            //         icon: const Icon(Icons.image),
            //         label: const Text("Pick Image"),
            //       ),
            // ],
            // ),
            // ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: GestureDetector(
                onTap: () {
                  // Implement Save Functionality
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
    );
  }
}
