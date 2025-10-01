import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../view_model/product_view_model.dart';
import 'widgets/product_card.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  void initState() {
    super.initState();
    print('ProductScreen - initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('ProductScreen - Starting to listen for products');
      context.read<ProductViewModel>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('ProductScreen - build called');
    
    return Scaffold(
      appBar: CustomAppBar(title: "Product"),
      body: SingleChildScrollView(
        child: Consumer<ProductViewModel>(
          builder: (context, provider, child) {
           
            
            // Debug: Print all products
            if (provider.products.isNotEmpty) {
              print('Products found:');
              for (int i = 0; i < provider.products.length; i++) {
                final product = provider.products[i];
                print('Product $i: ${product.productType} - ${product.brand} - ${product.productName}');
              }
            } else {
              print('No products in the list');
            }
            
            if (provider.isLoading) {
              print('Showing loading indicator');
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              print('Showing error: ${provider.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${provider.error}',
                      style: PTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        print('Retry button pressed');
                        provider.clearError();
                        provider.startListening(); // Restart listening
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (!provider.hasProducts) {
              print('Showing no products message');
              return Container(
                height: MediaQuery.of(context).size.height - 200, 
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Let's add your first product invoice",
                      style: PTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizeBoxH(16),
                    Text("No products added yet", style: PTextStyles.bodyLarge),
                    SizeBoxH(12),
                    CustomElavatedTextButton(
                      width: 180,
                      height: 40,
                      text: "Add Product",
                      onPressed: () {
                        print('Add Product button pressed');
                        Navigator.pushNamed(context, PPages.selectProductPageUi);
                      },
                    ),
                    SizeBoxH(20),
                   
                  ],
                ),
              );
            }

            print('Showing products list with ${provider.products.length} items');
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                 
                  SizeBoxH(16),
                  ListView.builder(
                    shrinkWrap: true, // Important for nested ListView
                    physics: NeverScrollableScrollPhysics(), // Disable inner scroll
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      final product = provider.products[index];
                      print('Building ProductCard for index $index: ${product.productType}');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ProductCard(product: product),
                      );
                    },
                  ),
                  
                ],
              ),
            );
            
          },
        ),
      ),
    
    );
  }
}