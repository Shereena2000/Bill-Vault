import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../../../../Service/cloudinary_service.dart';
import '../../model/product_model.dart';
import '../../view_model/product_view_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
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
                  // Device Icon and Type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.widgets,
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
                          product.productType.toUpperCase(),
                          style: PTextStyles.labelSmall.copyWith(
                            color: Colors.grey[400],
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "${product.brand} ${product.productName}",
                          style: PTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteDialog(context, product);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Product'),
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
                      "Purchase Date",
                      DateFormat('dd MMM, yyyy').format(product.purchaseDate),
                    ),
                  ),
                  Expanded(
                    child: _buildDetailItem(
                      "Warranty Upto",
                      DateFormat('dd MMM, yyyy').format(product.warrantyEndDate),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Warranty Status
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: product.isWarrantyActive 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: product.isWarrantyActive 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            product.isWarrantyActive ? Icons.verified : Icons.error,
                            color: product.isWarrantyActive ? Colors.green : Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              product.warrantyRemainingText,
                              style: PTextStyles.bodyMedium.copyWith(
                                color: product.isWarrantyActive ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizeBoxV(12),
                  // Bill Image
                  GestureDetector(
                    onTap: () {
                      if (product.billImageUrl != null) {
                        _showImageDialog(context, product.billImageUrl!);
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.billImageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: CloudinaryService.getOptimizedImageUrl(
                                  product.billImageUrl!,
                                  width: 40,
                                  height: 40,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => 
                                    Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (context, url, error) => 
                                    Icon(Icons.error, size: 20),
                              )
                            : Icon(Icons.receipt, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<ProductViewModel>().deleteProduct(product.id!);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  title: Text('Bill Image'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Flexible(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => 
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => 
                        Center(child: Icon(Icons.error)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
