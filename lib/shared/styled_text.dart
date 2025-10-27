import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StyledText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final FontStyle fontStyle;
  final IconData? icon;
  final double? iconSize;
  final Color? iconColor;

  const StyledText({
    super.key,
    required this.text,
    this.fontSize = 16,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign = TextAlign.start,
    this.fontStyle = FontStyle.normal,
    this.icon,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      text,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
        fontStyle: fontStyle,
      ),
    );
    if (icon == null) {
      return textWidget;
    }

    return Row(
      children: [
        Icon(icon, size: iconSize ?? fontSize + 2, color: iconColor),
        const SizedBox(width: 8),
        textWidget,
      ],
    );
  }
}
