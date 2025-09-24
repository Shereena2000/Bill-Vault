import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Features/product_screens/pruchase_detail/view/ui.dart';
import '../../Features/product_screens/pruchase_detail/view_model/purchase_detail_vm.dart';
import '../../Features/product_screens/select_brand/view/ui.dart';
import '../../Features/product_screens/select_product/view/ui.dart';
import '../../Features/product_screens/select_warranty_period/view/ui.dart';
import '../../Features/splash/view/ui.dart';
import '../../Features/wrapper/view/ui.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => SplashScreen());

      case PPages.wrapperPageUi:
        return MaterialPageRoute(builder: (context) => WrapperScreen());
        
      case PPages.selectProductPageUi:
        return MaterialPageRoute(builder: (context) => SelectProductScreen());
        
      case PPages.selectbrandPageUi:
        final productType = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => SelectBrandScreen(productType: productType)
        );
        
      case PPages.purchaseDetailPageUi:
        final args = settings.arguments as Map<String, String>?;
        print('PurchaseDetail route - args received: $args'); // Debug
        
        return MaterialPageRoute(
          settings: settings, // Pass the original settings
          builder: (context) => ChangeNotifierProvider(
            create: (_) {
              final viewModel = PurchaseDetailViewModel();
              // Set the product details immediately after creation
              if (args != null) {
                print('Route args received: $args'); // Debug log
                viewModel.setProductDetails(
                  args['productType'] ?? '',
                  args['productName'] ?? '',
                  args['brand'] ?? '',
                );
              } else {
                print('No args received in route'); // Debug log
              }
              return viewModel;
            },
            child: PurchaseDetailScreen(),
          ),
        );
        
      case PPages.selectWarrantyPeriodPageUi:
        return MaterialPageRoute(
          settings: settings, // Important: Pass settings so arguments are available
          builder: (context) => SelectWarrantyPeriodScreen()
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}