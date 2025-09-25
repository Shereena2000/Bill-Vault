
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../model/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onDelete;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PColors.darkGray,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Subscription Icon and Type
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getSubscriptionIcon(subscription.subscriptionType),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.subscriptionType.toUpperCase(),
                        style: PTextStyles.labelSmall.copyWith(
                          color: Colors.grey[400],
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "${subscription.brand} ${subscription.subscriptionName}",
                        style: PTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Subscription'),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 20),

            // Details Grid
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    "Registration Date",
                    DateFormat('dd MMM, yyyy').format(subscription.registrationDate),
                  ),
                ),
                Expanded(
                  child: _buildDetailItem(
                    "Next Billing",
                    DateFormat('dd MMM, yyyy').format(subscription.nextBillingDate),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Recurring Period and Status
            Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                    "Billing Cycle",
                    subscription.recurringPeriod,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(subscription).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(subscription).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(subscription),
                          color: _getStatusColor(subscription),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            subscription.daysUntilNextBilling,
                            style: PTextStyles.bodyMedium.copyWith(
                              color: _getStatusColor(subscription),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PTextStyles.labelSmall.copyWith(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: PTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  IconData _getSubscriptionIcon(String type) {
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

  Color _getStatusColor(SubscriptionModel subscription) {
    if (subscription.isOverdue) {
      return Colors.red;
    } else if (subscription.isDueSoon) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon(SubscriptionModel subscription) {
    if (subscription.isOverdue) {
      return Icons.error;
    } else if (subscription.isDueSoon) {
      return Icons.warning;
    } else {
      return Icons.check_circle;
    }
  }
}