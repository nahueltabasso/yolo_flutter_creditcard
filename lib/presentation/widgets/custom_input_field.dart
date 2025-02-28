import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {

  final String label;
  final String initialValue;
  final TextInputType keyboardType;
  final bool autocorrect;
  final IconData prefixIcon;
  final bool? enabled;
  final Function(String) onChanged;

  const CustomInputField({
    super.key, 
    required this.label, 
    required this.initialValue, 
    required this.keyboardType, 
    required this.autocorrect, 
    required this.prefixIcon, 
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(prefixIcon),
        ),
        autocorrect: autocorrect,
        keyboardType: keyboardType,
        initialValue: initialValue,
        enabled: enabled,
        onChanged: onChanged,
      )
    );  
  }
}