import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../../commom_widgets/custom_outline_button.dart';
import '../../product/model/product_data.dart';
import '../view_model/purchase_detail_vm.dart';
import 'widget/calender_widget.dart';

class PurchaseDetailScreen extends StatefulWidget {
  const PurchaseDetailScreen({super.key});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('PurchaseDetailScreen - didChangeDependencies called');
    
    // Get the arguments - they should be available now
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    print('Arguments in didChangeDependencies: $args');
  }

  @override
  Widget build(BuildContext context) {
    print('PurchaseDetailScreen - build called');
    
    return Scaffold(
      appBar: CustomAppBar(title: "Purchase Date"),
      body: Consumer<PurchaseDetailViewModel>(
        builder: (context, provider, child) {
          print('Consumer builder called - isLoading: ${provider.isLoading}');
          
          if (provider.isLoading) {
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                
                Text(
                  "Select Your Purchase Date",
                  style: PTextStyles.headlineMedium,
                ),
                SizeBoxH(16),
                CalenderWidget(),
                SizeBoxH(30),
                
                // Bill Upload Section
                Text(
                  "Upload Bill/Invoice (Optional)",
                  style: PTextStyles.headlineSmall,
                ),
                SizeBoxH(12),
                
                if (provider.hasBillImage)
                  _buildImagePreview(context, provider)
                else
                  _buildUploadOptions(context, provider),
                
                if (provider.error != null) ...[
                  SizeBoxH(16),
                  Container(
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
                            provider.error!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: provider.clearError,
                          child: Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ],
                
              
                
                Spacer(),
                
                CustomElavatedTextButton(
                  text: "Continue",
                  onPressed: (provider.productType != null && 
                              provider.productName != null && 
                              provider.brand != null) ? () {
                    print('=== CONTINUE BUTTON PRESSED ===');
                    
                    // Create ProductData from provider data
                    final productData = ProductData(
                      productType: provider.productType!,
                      productName: provider.productName!,
                      brand: provider.brand!,
                      purchaseDate: provider.purchaseDate,
                      billImagePath: provider.billImage?.path,
                    );
                    
                    print('Created ProductData: $productData');
                    
                    try {
                      // Navigate to warranty screen with ProductData
                      Navigator.pushNamed(
                        context, 
                        PPages.selectWarrantyPeriodPageUi,
                        arguments: productData,
                      );
                      print('Navigation completed');
                    } catch (e) {
                      print('Navigation error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigation error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                ),
                SizeBoxH(16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadOptions(BuildContext context, PurchaseDetailViewModel provider) {
    return Column(
      children: [
        CustomOutlineButton(
          onPressed: () => _showImageSourceDialog(context, provider),
          text: "Upload Bill/Invoice",
        ),
        SizeBoxH(12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => provider.pickBillImage(),
                icon: Icon(Icons.photo_library, size: 20),
                label: Text('Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => provider.takeBillPhoto(),
                icon: Icon(Icons.camera_alt, size: 20),
                label: Text('Camera'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, PurchaseDetailViewModel provider) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PColors.mediumGray),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              provider.billImage!,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: provider.removeBillImage,
                icon: Icon(Icons.close, color: Colors.white, size: 20),
                constraints: BoxConstraints(minHeight: 36, minWidth: 36),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Bill Image',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, PurchaseDetailViewModel provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.takeBillPhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  provider.pickBillImage();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}