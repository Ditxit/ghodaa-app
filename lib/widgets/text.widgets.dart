import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fontColor;
  final bool underline;
  final double marginTop;
  final double marginRight;
  final double marginBottom;
  final double marginLeft;

  const CustomText({
    super.key,
    this.text = '',
    this.fontSize = 16,
    this.fontColor = const Color.fromARGB(255, 0, 0, 0),
    this.underline = false,
    this.marginTop = 0,
    this.marginRight = 0,
    this.marginBottom = 0,
    this.marginLeft = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: marginTop,
          right: marginRight,
          bottom: marginBottom,
          left: marginLeft),
      child: Text(text,
          style: GoogleFonts.lato(
            textStyle: TextStyle(
              color: fontColor,
            ),
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            decoration:
                underline ? TextDecoration.underline : TextDecoration.none,
            decorationColor: fontColor,

            // fontStyle: FontStyle.italic,
          )
          // style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
          ),
    );
  }
}
