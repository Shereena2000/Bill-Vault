import 'package:bill_vault/Features/auth/view_model/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../Features/contact_screens/contact/view_model/contact_view_model.dart';
import '../../Features/product_screens/product/view_model/product_view_model.dart';
import '../../Features/product_screens/pruchase_detail/view_model/purchase_detail_vm.dart';
import '../../Features/product_screens/select_brand/view_model/select_view_model.dart';
import '../../Features/product_screens/select_product/view_model/select_view_model.dart';
import '../../Features/product_screens/select_warranty_period/view/view_model/select_warranty_viewmodel.dart';
import '../../Features/subscription_screens/selectSubscriptionBrandScreen/view_model/sub_brand_view_model.dart';
import '../../Features/subscription_screens/select_sub_reccurring_period/view_model.dart/sub_reccurring_period_view_model.dart';
import '../../Features/subscription_screens/select_subscription_type/view_model/subscription_type_view_model.dart';
import '../../Features/subscription_screens/subscription_registration_date/view_model/subscription_reg_view_model.dart';
import '../../Features/subscription_screens/subscriptions/view_model/subscriotions_view_model.dart';
import '../../Features/wrapper/view_model/wrapper_view_model.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider(create: (_) => WrapperViewModel()),
  ChangeNotifierProvider(create: (_) => AuthViewModel()),

  ChangeNotifierProvider(create: (_) => ProductViewModel()),
  ChangeNotifierProvider(create: (_) => SelectProductViewModel()),
  ChangeNotifierProvider(create: (_) => SelectBrandViewModel()),
  ChangeNotifierProvider(create: (_) => PurchaseDetailViewModel()),
  ChangeNotifierProvider(create: (_) => SelectWarrantyViewModel()),
  ChangeNotifierProvider(create: (_) => ContactViewModel()),
  ChangeNotifierProvider(create: (_) => SubscriptionViewModel()),
  ChangeNotifierProvider(create: (_) => SelectSubscriptionTypeViewModel()),
    ChangeNotifierProvider(create: (_) => SelectSubscriptionBrandViewModel()),
  ChangeNotifierProvider(create: (_) => SubscriptionRegistrationDateViewModel()),
  ChangeNotifierProvider(create: (_) => SelectSubscriptionRecurringPeriodViewModel()),
];
