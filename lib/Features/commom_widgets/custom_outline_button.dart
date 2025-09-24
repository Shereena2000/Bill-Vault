import 'package:flutter/material.dart';

import '../../Settings/constants/text_styles.dart';
import '../../Settings/utils/p_colors.dart';



class CustomOutlineButton extends StatelessWidget {
  final String text;
  final double? width;
  final double? heigth;
  final double? borderRaduis; final double? fontSize;
  final Color? bordercolor;
  final Color? forgcolor;
  final double? padverticle;
  final double? padhorizondal;
  final Function() onPressed;

  const CustomOutlineButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.heigth,
    this.bordercolor,
    this.forgcolor,
    this.borderRaduis,
    this.padverticle,
    this.padhorizondal, this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return ElevatedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: forgcolor ?? PColors.black,
        foregroundColor: forgcolor ?? PColors.red,
        // padding: EdgeInsets.symmetric(
        //     vertical: padverticle ?? 8, horizontal: padhorizondal ?? 16),
        fixedSize: Size(width ?? size.width - 32, heigth ?? 50),
        minimumSize: Size(width ?? size.width - 32, heigth ?? 50),
        maximumSize: Size(width ?? size.width - 32, heigth ?? 50),
        side: BorderSide(
          width: 1,
          color: bordercolor ?? PColors.red,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRaduis ?? 8),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: getTextStyle(
          fontSize:fontSize?? 16,
          color: PColors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
