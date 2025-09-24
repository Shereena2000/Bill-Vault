import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../Features/product_screens/product/view_model/product_view_model.dart';
import '../../Features/product_screens/pruchase_detail/view_model/purchase_detail_vm.dart';
import '../../Features/product_screens/select_brand/view_model/select_view_model.dart';
import '../../Features/product_screens/select_product/view_model/select_view_model.dart';
import '../../Features/product_screens/select_warranty_period/view/view_model/select_warranty_viewmodel.dart';
import '../../Features/wrapper/view_model/wrapper_view_model.dart';

List<SingleChildWidget> providers = [
 ChangeNotifierProvider(create: (_) => WrapperViewModel()),
  
  // Product flow providers
  ChangeNotifierProvider(create: (_) => ProductViewModel()),
  ChangeNotifierProvider(create: (_) => SelectProductViewModel()),
  ChangeNotifierProvider(create: (_) => SelectBrandViewModel()),
  ChangeNotifierProvider(create: (_) => PurchaseDetailViewModel()),
  ChangeNotifierProvider(create: (_) => SelectWarrantyViewModel()),
  
];
