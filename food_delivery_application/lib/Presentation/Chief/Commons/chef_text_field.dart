import 'package:flutter/material.dart';
import 'package:food_delivery_app_project/Data/DataSource/Resources/color.dart';

class ChefTextField extends StatelessWidget {
  const ChefTextField({
    required this.hint,
    this.maxLines,
    required this.controller,
    required this.validator,
    this.keyboardType,
    this.save,
    super.key,
  });
  final String hint;
  final int? maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? Function(String?)? save;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: save,
      controller: controller,
      maxLines: maxLines,
      cursorColor: AppColor.mediumOrangeColor,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 220, 225, 229),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xff9C9BA6), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
        filled: true,
      ),
    );
  }
}
