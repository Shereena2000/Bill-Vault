import 'package:flutter/material.dart';

import '../../Settings/constants/text_styles.dart';
import '../../Settings/utils/p_colors.dart';


class CustomElavatedTextButton extends StatelessWidget {
  const CustomElavatedTextButton({
    super.key,
    this.onPressed,
    required this.text,
    this.width,
    this.height,
    this.padverticle,
    this.padhorizondal,
    this.fontSize,
    this.bgcolor,
    this.borderRadius,
    this.textColor,
    this.borderColor,
    this.icon,
    this.iconSpacing, this.prefixIcon, 
  });

  final void Function()? onPressed;
  final String text;
  final double? width;
  final double? height;
  final double? fontSize;
  final double? padverticle;
  final double? padhorizondal;
  final Color? bgcolor;
  final double? borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final Widget? icon; // ✅ optional icon
  final double? iconSpacing;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgcolor ?? PColors.red,
        padding: EdgeInsets.symmetric(
          vertical: padverticle ?? 8,
          horizontal: padhorizondal ?? 16,
        ),
        fixedSize: Size(width ?? size.width - 40, height ?? 50),
        maximumSize: Size(width ?? size.width - 40, height ?? 50),
        minimumSize: Size(width ?? size.width - 40, height ?? 50),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           if (prefixIcon != null) ...[
            SizedBox(width: iconSpacing ?? 8),
            prefixIcon!,
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: getTextStyle(
              fontSize: fontSize ?? 16,
              color: textColor ?? PColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (icon != null) ...[
            SizedBox(width: iconSpacing ?? 8),
            icon!,
          ],
        ],
      ),
    );
  }
}
