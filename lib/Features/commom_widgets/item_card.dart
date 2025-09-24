import 'package:flutter/material.dart';

import '../../Settings/utils/p_colors.dart';
import '../../Settings/utils/p_text_styles.dart';

class ItemCards extends StatelessWidget {
  const ItemCards({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PColors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title, 
            style: PTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}