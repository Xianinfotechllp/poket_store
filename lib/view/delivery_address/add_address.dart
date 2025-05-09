import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:poketstore/controllers/address_controller/address_controller.dart';
import 'package:poketstore/model/address_model/address_model.dart';
import 'package:provider/provider.dart';

class AddAddressPage extends StatefulWidget {
  final AddressModel? address;

  const AddAddressPage({Key? key, this.address}) : super(key: key);

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _houseController = TextEditingController();
  final _areaController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _townController = TextEditingController();
  String? _selectedCountry;
  String? _selectedState;
  final List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Andorra',
    'Angola',
    'Antigua and Barbuda',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahamas',
    'Bahrain',
    'Bangladesh',
    'Barbados',
    'Belarus',
    'Zambia',
    'Zimbabwe',
  ];
  final List<String> _states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Chandigarh',
    'Dadra and Nagar Haveli and Daman and Diu',
    'Lakshadweep',
    'Delhi',
    'Puducherry',
    'Ladakh',
    'Lakshadweep',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _selectedCountry = widget.address!.countryName;
      _phoneController.text = widget.address!.phoneNumber;
      _houseController.text = widget.address!.houseNo;
      _areaController.text = widget.address!.area;
      _landmarkController.text = widget.address!.landmark;
      _pincodeController.text = widget.address!.pincode;
      _townController.text = widget.address!.town;
      _selectedState = widget.address!.state;
      log('Editing existing address: ${widget.address!.toJson()}');
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _houseController.dispose();
    _areaController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    _townController.dispose();
    super.dispose();
  }

  void _submitAddress(BuildContext context) async {
    log('Submitting address form...');
    log('Phone: ${_phoneController.text}');
    log('House No: ${_houseController.text}');
    log('Area: ${_areaController.text}');
    log('Landmark: ${_landmarkController.text}');
    log('Pincode: ${_pincodeController.text}');
    log('Town: ${_townController.text}');
    log('Country: $_selectedCountry');
    log('State: $_selectedState');

    if (_formKey.currentState!.validate()) {
      final newAddress = AddressModel(
        countryName: _selectedCountry ?? '',
        phoneNumber: _phoneController.text.trim(),
        houseNo: _houseController.text.trim(),
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim(),
        pincode: _pincodeController.text.trim(),
        town: _townController.text.trim(),
        state: _selectedState ?? '',
        id: widget.address?.id,
      );

      log('Prepared AddressModel: ${newAddress.toJson()}');

      final addressController =
          Provider.of<AddressController>(context, listen: false);
      try {
        if (widget.address == null) {
          log('Calling addAddress...');
          await addressController.addAddress(newAddress);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address added successfully')),
          );
        } else {
          log('Calling updateAddress for ID: ${widget.address!.id}');
          await addressController.updateAddress(
              widget.address!.id!, newAddress);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Address updated successfully')),
          );
        }
      } catch (error) {
        log('Error during address submission: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
      Navigator.pop(context);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a $label' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AddressController>().isLoading;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.address == null ? 'Add Address' : 'Edit Address')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    _buildDropdown(
                      label: 'Country',
                      items: _countries,
                      selectedValue: _selectedCountry,
                      onChanged: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                    ),
                    _buildTextField(_phoneController, 'Phone Number',
                        keyboardType: TextInputType.phone),
                    _buildTextField(_houseController, 'House No'),
                    _buildTextField(_areaController, 'Area'),
                    _buildTextField(_landmarkController, 'Landmark'),
                    _buildTextField(_pincodeController, 'Pincode',
                        keyboardType: TextInputType.number),
                    _buildTextField(_townController, 'Town'),
                    _buildDropdown(
                      label: 'State',
                      items: _states,
                      selectedValue: _selectedState,
                      onChanged: (value) {
                        setState(() {
                          _selectedState = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _submitAddress(context),
                      child: Text(widget.address == null
                          ? 'Add Address'
                          : 'Update Address'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
