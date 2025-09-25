// Create this as: lib/Features/subscription_screens/view/widgets/subscription_brand_card.dart

import 'package:flutter/material.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';

class SubscriptionBrandCard extends StatelessWidget {
  final String title;
  final String subscriptionType;
  final VoidCallback onTap;
  
  const SubscriptionBrandCard({
    super.key, 
    required this.title, 
    required this.subscriptionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}