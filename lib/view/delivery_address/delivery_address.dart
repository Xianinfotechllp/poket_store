import 'package:flutter/material.dart';
import 'package:poketstore/view/delivery_address/add_delivery_address.dart';

class AddressListScreen extends StatefulWidget {
  @override
  _AddressListScreenState createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final List<String> addresses = [
    "123 Main Street, New York, NY",
    "456 Oak Avenue, Los Angeles, CA",
    "789 Pine Road, Chicago, IL",
  ];

  int? selectedIndex; // Tracks selected address index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Saved Addresses", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body:
          addresses.isEmpty
              ? Center(
                child: Text(
                  "No addresses saved",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedIndex == index;
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 4,
                    color:
                        isSelected
                            ? Color(0xFF094497).withOpacity(0.1)
                            : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                        color:
                            isSelected ? Color(0xFF094497) : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      title: Text(
                        addresses[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Checkbox(
                        value: isSelected,
                        activeColor: Color(0xFF094497),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            selectedIndex = value == true ? index : null;
                          });
                        },
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          // TODO: Implement delete function
                        },
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAddressScreen()),
          );
        },
        label: Text("Add Address", style: TextStyle(color: Colors.white)),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF094497),
        elevation: 4,
      ),
    );
  }
}
