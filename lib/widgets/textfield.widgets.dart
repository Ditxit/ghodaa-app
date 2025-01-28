import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String? hintText;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;

  const CustomTextField({
    super.key, 
    this.hintText = '', 
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.marginLeft = 0,
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: marginTop, right: marginRight, bottom: marginBottom, left: marginLeft ),
      child: SizedBox(
        height: 60,
        child: TextField(
          decoration: InputDecoration(
              hintText: hintText,
              contentPadding: EdgeInsets.all(20.0),
              filled: true,
              fillColor: const Color.fromARGB(255, 244, 253, 250),
              border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10))),
        ),
      ),
    );
  }
}
