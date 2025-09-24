import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bill_vault/Settings/utils/p_pages.dart';
import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../contact_screens/contact/view/ui.dart';
import '../../product_screens/product/view/ui.dart';
import '../../subscriptions/view/ui.dart';
import '../view_model/wrapper_view_model.dart';

class WrapperScreen extends StatelessWidget {
  WrapperScreen({super.key});

  final List<Widget> _pages = [
    ProductScreen(),
    ContactScreen(),
    SubscriptionsScreen(),
    ProductScreen(),
  ];

  final List<IconData> _iconList = [
    Icons.account_balance_wallet_outlined,
    Icons.people_outline,
    Icons.savings_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WrapperViewModel>(context);

    return Scaffold(
      body: _pages[provider.currentindex],

      floatingActionButton: FloatingActionButton(
        backgroundColor: PColors.red,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return SizedBox(
                height: 250,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: PColors.lightGray,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Add", style: PTextStyles.displaySmall),
                    ListTile(
                      leading: Icon(Icons.account_balance_wallet),
                      title: Text("Product", style: PTextStyles.labelSmall),
                      onTap: () => Navigator.pushNamed(context, PPages.selectProductPageUi),
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text("Customer", style: PTextStyles.labelSmall),
                    ),
                    ListTile(
                      leading: Icon(Icons.savings_outlined),
                      title: Text(
                        "Subscriotion",
                        style: PTextStyles.labelSmall,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.endDocked, // ✅ Changed to edge

      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: provider.currentindex == 3
            ? -1 // No tab highlighted when FAB page is active
            : provider.currentindex,
        backgroundColor: PColors.darkGray,
        activeColor: PColors.red,
        inactiveColor: PColors.white,
        gapLocation: GapLocation.end, // ✅ Gap at end for FAB
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          provider.updateIndex(index); // Only 0-2 from tabs
        },
      ),
    );
  }
}
