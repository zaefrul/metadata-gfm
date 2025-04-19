import 'package:flutter/material.dart';

Widget field(
  String hint,
  ValueChanged<String> onChange, {
  bool secure = false,
  String? asset,
  IconData? leftIcon,
  Widget? rightIcon,
  double horizontal = 20.0,
  String? value,
  bool enable = true,
  bool phoneType = false,
}) {
  TextEditingController? controller =
      value == null ? null : TextEditingController(text: value);

  Widget? child;
  if (asset != null) {
    child = Image.asset(
      asset,
      height: 15.0,
      width: 15.0,
    );
  }

  return Padding(
    padding: EdgeInsets.symmetric(horizontal: horizontal),
    child: TextField(
      onSubmitted: (String text) {
        print("tapped");
      },
      keyboardType: phoneType ? TextInputType.phone : null,
      enabled: enable,
      controller: controller,
      obscureText: secure,
      decoration: InputDecoration(
        prefixIcon: leftIcon == null || child == null
            ? null
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: child,
              ),
        suffixIcon: rightIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: rightIcon,
              ),
        labelText: hint,
      ),
      onChanged: onChange,
    ),
  );
}
