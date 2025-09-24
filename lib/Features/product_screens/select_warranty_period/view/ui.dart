import 'dart:io';
import 'package:bill_vault/Settings/constants/sized_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/utils/p_colors.dart';
import '../../../../Service/firebase_service.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../product/model/product_data.dart';
import '../../product/model/product_model.dart';
import 'view_model/select_warranty_viewmodel.dart';

class SelectWarrantyPeriodScreen extends StatefulWidget {
  const SelectWarrantyPeriodScreen({super.key});

  @override
  State<SelectWarrantyPeriodScreen> createState() => _SelectWarrantyPeriodScreenState();
}

class _SelectWarrantyPeriodScreenState extends State<SelectWarrantyPeriodScreen> {
  ProductData? productData;
  bool isLoading = false;
  String? error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Extract ProductData from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is ProductData && productData == null) {
      productData = args;
      print('ProductData received in warranty screen: $productData');
    }
  }

  DateTime _calculateWarrantyEndDate(String warrantyPeriod, DateTime purchaseDate) {
    final period = warrantyPeriod.toLowerCase();
    if (period.contains('month')) {
      final months = int.tryParse(period.split(' ').first) ?? 12;
      return DateTime(purchaseDate.year, purchaseDate.month + months, purchaseDate.day);
    } else if (period.contains('year')) {
      final years = int.tryParse(period.split(' ').first) ?? 1;
      return DateTime(purchaseDate.year + years, purchaseDate.month, purchaseDate.day);
    }
    
    return DateTime(purchaseDate.year + 1, purchaseDate.month, purchaseDate.day);
  }

  Future<void> saveProduct(String warrantyPeriod) async {
    if (productData == null) {
      setState(() {
        error = 'Product data is missing';
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      String? billImageUrl;
      
      // Upload bill image if exists
      if (productData!.billImagePath != null) {
        print('Uploading bill image...');
        final imageFile = File(productData!.billImagePath!);
        billImageUrl = await FirebaseService.uploadBillImage(imageFile, 'temp');
        print('Bill image uploaded: $billImageUrl');
      }

      final warrantyEndDate = _calculateWarrantyEndDate(warrantyPeriod, productData!.purchaseDate);
      final isWarrantyActive = warrantyEndDate.isAfter(DateTime.now());

      final product = ProductModel(
        productType: productData!.productType,
        productName: productData!.productName,
        brand: productData!.brand,
        purchaseDate: productData!.purchaseDate,
        warrantyEndDate: warrantyEndDate,
        billImageUrl: billImageUrl,
        warrantyPeriod: warrantyPeriod,
        isWarrantyActive: isWarrantyActive,
      );

      print('Saving product to Firebase...');
      print('Product details:');
      print('- Product Type: ${product.productType}');
      print('- Product Name: ${product.productName}');
      print('- Brand: ${product.brand}');
      print('- Purchase Date: ${product.purchaseDate}');
      print('- Warranty Period: ${product.warrantyPeriod}');
      
      await FirebaseService.addProduct(product);
      print('Product saved successfully!');
      
      setState(() {
        isLoading = false;
      });

      // Navigate back to home and show success
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      print('Error saving product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Select Warranty Period"),
      body: Consumer<SelectWarrantyViewModel>(
        builder: (context, warrantyProvider, child) {
          if (isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving product...'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Show product info
                if (productData != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Product: ${productData!.productType}'),
                        Text('Brand: ${productData!.brand}'),
                        Text('Name: ${productData!.productName}'),
                        Text('Purchase Date: ${productData!.purchaseDate.toString().split(' ')[0]}'),
                        if (productData!.billImagePath != null)
                          Text('Bill Image: Available'),
                      ],
                    ),
                  ),
                  SizeBoxH(16),
                ],
                
                Expanded(
                  child: GridView.builder(
                    itemCount: warrantyProvider.warrantyPeriods.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      final period = warrantyProvider.warrantyPeriods[index];
                      final isSelected = warrantyProvider.selectedWarrantyPeriod == period;
                      
                      return GestureDetector(
                        onTap: () => warrantyProvider.selectWarrantyPeriod(period),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? PColors.red : PColors.darkGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? PColors.red : PColors.mediumGray,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              period,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                if (error != null) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            error!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              error = null;
                            });
                          },
                          child: Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ],
                
                CustomElavatedTextButton(
                  text: warrantyProvider.hasSelection ? "SAVE PRODUCT" : "SELECT WARRANTY PERIOD",
                  onPressed: warrantyProvider.hasSelection && productData != null
                      ? () async {
                          await saveProduct(warrantyProvider.selectedWarrantyPeriod!);
                          warrantyProvider.clearSelection();
                        }
                      : null,
                ),
                SizeBoxH(8),
              ],
            ),
          );
        },
      ),
    );
  }
}