import 'package:flutter/material.dart';

class MyTextFormField extends StatelessWidget {
  final String? Function(String?)? onValidate;
  final bool obscureText;
  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;

  MyTextFormField({
    super.key,
    required this.onValidate,
    required this.obscureText,
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    this.suffixIcon,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70.0, // Set a fixed height for all form fields
      child: TextFormField(
        style: TextStyle(color: Theme.of(context).secondaryHeaderColor),
        cursorColor: Theme.of(context).canvasColor,
        keyboardType: keyboardType,
        controller: controller,
        validator: onValidate,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0), // Consistent internal padding
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).secondaryHeaderColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: Theme.of(context).secondaryHeaderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: Theme.of(context).canvasColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
            borderSide: BorderSide(color: Colors.red),
          ),
          filled: true,
          fillColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
