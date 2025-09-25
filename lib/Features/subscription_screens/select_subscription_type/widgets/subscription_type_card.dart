// Create this as: lib/Features/subscription_screens/view/widgets/subscription_type_card.dart

import 'package:flutter/material.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../subscriptions/model/subscription_model.dart';

class SubscriptionTypeCard extends StatelessWidget {
  final String image;
  final String title;
  final SubscriptionTypeModel subscriptionType;
  final VoidCallback onTap;

  const SubscriptionTypeCard({
    super.key, 
    required this.image, 
    required this.title,
    required this.subscriptionType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 150,
        decoration: BoxDecoration(
          color: PColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ), 
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: _getGradientForType(title),
                  ),
                  child: Icon(
                    _getIconForType(title),
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    title, 
                    style: PTextStyles.labelMedium.copyWith(color: Colors.black),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getGradientForType(String type) {
    switch (type.toLowerCase()) {
      case 'gaming':
        return LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'music':
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'news':
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ott':
        return LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'saas platform':
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.grey.shade400, Colors.grey.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'gaming':
        return Icons.sports_esports;
      case 'music':
        return Icons.music_note;
      case 'news':
        return Icons.article;
      case 'ott':
        return Icons.live_tv;
      case 'saas platform':
        return Icons.cloud;
      default:
        return Icons.subscriptions;
    }
  }
}