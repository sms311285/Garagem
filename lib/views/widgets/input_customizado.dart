import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;
  final int? maxLines;
  final List<TextInputFormatter> inputFormatters;
  final String? Function(String?)? validator;
  final String? Function(String?)? onSaved;

  const InputCustomizado({
    Key? key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.autofocus = false,
    this.type = TextInputType.text,
    required this.inputFormatters,
    this.maxLines = 1,
    this.validator,
    this.onSaved
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      autofocus: autofocus,
      keyboardType: type,
      textCapitalization: TextCapitalization.words,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      onSaved: onSaved,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
    );
  }
}
