import 'package:flutter/material.dart';

Widget field(String hint, Function(String) onChange,
    {bool secure = false,
    String asset,
    IconData leftIcon,
    Widget rightIcon,
    double horizontal = 20.0,
    String value,
    bool enable = true,
    bool phoneType = false}) {
  Widget child;
  TextEditingController controller =
      value == null ? null : TextEditingController(text: value);

  if (asset != null)
    child = new Image.asset(
      asset,
      height: 15.0,
      width: 15.0,
    );
  else if (leftIcon != null) child = Icon(leftIcon);

  return new Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal),
      child: new TextField(
          onSubmitted: (String text) {
            print("tapped");
          },
          keyboardType: phoneType ? TextInputType.phone : null,
          enabled: enable,
          controller: controller,
          // style: new TextStyle(fontFamily: 'Avenir'),
          obscureText: secure,
          decoration: InputDecoration(
              prefixIcon: leftIcon == null
                  ? null
                  : Padding(padding: EdgeInsets.all(10.0), child: child),
              suffixIcon: rightIcon == null
                  ? null
                  : Padding(padding: EdgeInsets.all(10.0), child: rightIcon),
              labelText: hint),
          onChanged: onChange));
}
