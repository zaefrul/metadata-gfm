import 'package:flutter/material.dart';


class Button extends StatelessWidget {
  final GestureTapCallback onPressed;
  final String text;
  final Color color;

  Button({required this.onPressed, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        // backgroundColor: color == null ? colorTheme1 : color,
        shape: StadiumBorder(),
      ),
      onPressed: this.onPressed,
      child: new Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
