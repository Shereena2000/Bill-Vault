import 'package:flutter/material.dart';
import '../../Settings/utils/p_pages.dart';
import 'item_card.dart';

// class ItemCard extends StatelessWidget {
//   final String title;
//   const ItemCard({super.key, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushNamed(context, PPages.purchaseDetailPageUi);
//       },
//       child: Container(
//         color: PColors.red,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [Text(title, style: PTextStyles.bodyMedium)],
//         ),
//       ),
//     );
//   }
// }

class BrandItemCard extends StatelessWidget {
  final String title;
  final String productType;
  
  const BrandItemCard({
    super.key, 
    required this.title, 
    required this.productType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pass product details to purchase detail screen
        Navigator.pushNamed(
          context, 
          PPages.purchaseDetailPageUi,
          arguments: {
            'productType': productType,
            'productName': productType, // You can customize this
            'brand': title,
          },
        );
      },
      child: ItemCards(title: title),
    );
  }
}

