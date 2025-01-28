import 'package:flutter/material.dart';
import 'package:ghodaa/widgets/text.widgets.dart';

class CustomSolidButton extends StatelessWidget {
  final String text;
  final double fontSize;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;

  final VoidCallback onPressed;

  const CustomSolidButton({
    super.key,
    this.text = '',
    this.fontSize = 18,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.marginLeft = 0,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: marginTop,
          right: marginRight,
          bottom: marginBottom,
          left: marginLeft),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: TextButton(
          style: ButtonStyle(
            // foregroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: WidgetStateProperty.all<Color>(
                const Color.fromARGB(255, 255, 255, 255)),
            backgroundColor: WidgetStateProperty.all<Color>(
                const Color.fromARGB(255, 35, 196, 145)),
          ),
          onPressed: onPressed,
          child: CustomText(
            text: text,
            fontSize: fontSize,
            fontColor: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }
}
