import 'package:bill_vault/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';

import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../product/model/product_model.dart';

class ProductsCard extends StatelessWidget {
  final String image;
  final String title;
  final ProductTypeModel productType;

  const ProductsCard({
    super.key, 
    required this.image, 
    required this.title,
    required this.productType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context, 
          PPages.selectbrandPageUi,
          arguments: productType.name, // Pass the product type name
        );
      },
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
                child: Image.asset(
                  image, 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: PColors.darkGray,
                      child: Icon(Icons.error, color: Colors.grey),
                    );
                  },
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
}
