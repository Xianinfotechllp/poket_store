import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poketstore/controllers/login_reg_controller/registration_controller.dart';
import 'package:poketstore/view/login/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: provider.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Let's Get Started!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Create an account to get all features',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),

                      // Input fields
                      ..._buildInputFields(provider),

                      // Password
                      _buildPasswordField(
                        label: "Password",
                        controller: provider.passwordController,
                        hidden: _hidePassword,
                        toggleVisibility: () =>
                            setState(() => _hidePassword = !_hidePassword),
                      ),
                      _buildPasswordField(
                        label: "Confirm Password",
                        controller: provider.confirmPasswordController,
                        hidden: _hideConfirmPassword,
                        toggleVisibility: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword),
                        validator: provider.validateConfirmPassword,
                      ),

                      const SizedBox(height: 20),

                      // Register button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: provider.isLoading
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  final success =
                                      await provider.register(context);
                                  if (success) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LoginScreen()),
                                    );
                                    // Clear after navigation completes
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      provider.clearTextFields();
                                    });
                                  }
                                },
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Register',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white)),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account?",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              );
                            },
                            child: const Text("Login here",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputFields(RegistrationProvider provider) {
    final fields = [
      {
        'label': 'Full Name',
        'icon': Icons.person,
        'controller': provider.nameController,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Full Name";
          }
          if (value.length < 4) {
            return "Full Name must be at least 4 characters";
          }
          return null;
        }
      },
      {
        'label': 'Mobile Number',
        'icon': Icons.phone_android,
        'controller': provider.mobileController,
        'isNumber': true,
        'validator': (value) {
          if (value == null || value.isEmpty) {
            return "Please enter your Mobile Number";
          }
          if (value.length < 10) {
            return "Mobile Number must be at least 10 digits";
          }
          return null;
        }
      },
      {
        'label': 'State',
        'icon': Icons.place_outlined,
        'controller': provider.stateController
      },
      {
        'label': 'District',
        'icon': Icons.map_outlined,
        'controller': provider.placeController
      },
      {
        'label': 'Locality / Area',
        'icon': Icons.location_city,
        'controller': provider.localityController
      },
      {
        'label': 'Pin Code',
        'icon': Icons.pin_outlined,
        'controller': provider.pincodeController,
        'isNumber': true
      },
    ];

    return fields.map((field) {
      final FormFieldValidator<String>? customValidator =
          field['validator'] as FormFieldValidator<String>?;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: field['controller'] as TextEditingController,
          keyboardType: field['isNumber'] == true
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: field['label'] as String,
            prefixIcon: Icon(field['icon'] as IconData),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          validator: customValidator ??
              (value) => (value == null || value.isEmpty)
                  ? "Please enter ${field['label']}"
                  : null,
        ),
      );
    }).toList();
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool hidden,
    required VoidCallback toggleVisibility,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: hidden,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(hidden ? Icons.visibility_off : Icons.visibility),
            onPressed: toggleVisibility,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) return "Please enter $label";
              if (label == "Password" && value.length < 6)
                return "Password must be at least 6 characters";
              return null;
            },
      ),
    );
  }
}
