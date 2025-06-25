import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController productNameController;
  final TextEditingController localityController;
  final TextEditingController shopNameController; // ✅ New field
  final VoidCallback onSearch;
  final ValueChanged<bool> onSearchExpanded;

  const SearchBarWidget({
    Key? key,
    required this.productNameController,
    required this.localityController,
    required this.shopNameController, // ✅ New param
    required this.onSearch,
    required this.onSearchExpanded,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isSearchExpanded = false;
  bool _showLocationField = false;

  @override
  void initState() {
    super.initState();
    widget.productNameController.addListener(_onSearchFieldChanged);
    widget.localityController.addListener(_onSearchFieldChanged);
    widget.shopNameController.addListener(_onSearchFieldChanged); // ✅
  }

  void _onSearchFieldChanged() {
    if (widget.productNameController.text.isEmpty &&
        widget.localityController.text.isEmpty &&
        widget.shopNameController.text.isEmpty &&
        _isSearchExpanded) {
      setState(() {
        _isSearchExpanded = false;
        _showLocationField = false;
      });
      widget.onSearchExpanded(_isSearchExpanded);
    }
  }

  @override
  void dispose() {
    widget.productNameController.removeListener(_onSearchFieldChanged);
    widget.localityController.removeListener(_onSearchFieldChanged);
    widget.shopNameController.removeListener(_onSearchFieldChanged); // ✅
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      height:
          _isSearchExpanded
              ? (_showLocationField ? 200 : 70) // Adjusted height
              : 70,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isSearchExpanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.search, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: widget.productNameController,
                    decoration: const InputDecoration(
                      hintText: "What are you looking for?",
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      setState(() => _isSearchExpanded = true);
                      widget.onSearchExpanded(_isSearchExpanded);
                    },
                    onSubmitted: (_) => widget.onSearch(),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showLocationField = !_showLocationField;
                      if (_showLocationField) {
                        _isSearchExpanded = true;
                      }
                    });
                    widget.onSearchExpanded(_isSearchExpanded);
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child:
                        _showLocationField
                            ? const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 28,
                              key: ValueKey(1),
                            )
                            : const Icon(
                              Icons.location_on_outlined,
                              color: Colors.grey,
                              size: 28,
                              key: ValueKey(2),
                            ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSearchExpanded ? 100 : 0,
                  child:
                      _isSearchExpanded
                          ? ElevatedButton(
                            onPressed: widget.onSearch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF094497),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Search",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child:
                _showLocationField
                    ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.pin_drop, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: widget.localityController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter location (optional)",
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => widget.onSearch(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.store, color: Colors.grey),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: widget.shopNameController,
                                  decoration: const InputDecoration(
                                    hintText: "Enter shop name (optional)",
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => widget.onSearch(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
