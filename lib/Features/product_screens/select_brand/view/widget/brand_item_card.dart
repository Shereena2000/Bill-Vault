import 'package:flutter/material.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Settings/utils/p_pages.dart';



class BrandItemCard extends StatelessWidget {
  final String title; // This is the brand name
  final String productType; // This is the product type
  
  const BrandItemCard({
    super.key, 
    required this.title, 
    required this.productType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('BrandItemCard tapped:'); // Debug log
        print('Product Type: $productType'); // Debug log
        print('Brand: $title'); // Debug log
        
        // Navigate to purchase detail with product information
        Navigator.pushNamed(
          context, 
          PPages.purchaseDetailPageUi,
          arguments: {
            'productType': productType,
            'productName': productType, // Use productType as productName for now, or create a more specific naming system
            'brand': title,
          },
        );
      },
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