import 'package:flutter/material.dart';
import 'package:novel_app/utils/app_text_styles.dart';

class AppDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? selectedItem;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.selectedItem,
  });

  @override
  AppDropdownState createState() => AppDropdownState();
}

class AppDropdownState extends State<AppDropdown> {
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: SizedBox(
          height: 54,
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedItem,
            hint: Text(
              widget.label,
              style: AppTextStyles.hintInputText,
            ),
            icon: const Icon(Icons.arrow_drop_down),
            items: widget.items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: AppTextStyles.inputText,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedItem = newValue;
              });
              widget.onChanged(newValue!);
            },
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(30),
            style: AppTextStyles.inputText,
          ),
        ),
      ),
    );
  }
}
