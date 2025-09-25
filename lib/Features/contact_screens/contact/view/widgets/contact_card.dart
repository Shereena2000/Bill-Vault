
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../model/contact_model.dart';


class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: PColors.darkGray,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: PColors.red,
                  radius: 25,
                  child: Text(
                    contact.initials,
                    style: PTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizeBoxV(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.name,
                        style: PTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizeBoxH(4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: PColors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contact.profession,
                          style: PTextStyles.labelSmall.copyWith(
                            color: PColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizeBoxV(8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizeBoxV(8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizeBoxH(12),
            
            // Phone Row
            Row(
              children: [
                Icon(Icons.phone, size: 18, color: Colors.grey[400]),
                SizeBoxV(8),
                Expanded(
                  child: Text(
                    contact.phone,
                    style: PTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[300],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _makePhoneCall(contact.phone, context),
                  icon: Icon(Icons.call, color: Colors.green),
                  tooltip: 'Call ${contact.name}',
                ),
              ],
            ),
            
            SizeBoxH(8),
            
            // Added date
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                SizeBoxV(6),
                Text(
                  'Added ${_formatDate(contact.createdAt)}',
                  style: PTextStyles.labelSmall.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _makePhoneCall(String phoneNumber, BuildContext context) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making phone call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    }
  }
}