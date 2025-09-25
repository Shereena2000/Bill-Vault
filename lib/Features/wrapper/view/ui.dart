import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:bill_vault/Settings/utils/p_pages.dart';
import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Settings/utils/p_colors.dart';
import '../../../Settings/constants/sized_box.dart';

import '../../commom_widgets/custom_text_feild.dart';
import '../../contact_screens/contact/view/ui.dart';
import '../../contact_screens/contact/view_model/contact_view_model.dart';
import '../../product_screens/product/view/ui.dart';
import '../../subscription_screens/subscriptions/view/ui.dart';
import '../view_model/wrapper_view_model.dart';

class WrapperScreen extends StatelessWidget {
  WrapperScreen({super.key});

  final List<Widget> _pages = [
    ProductScreen(),
    ContactScreen(),
    SubscriptionScreen(),
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
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet first
                        Navigator.pushNamed(
                          context,
                          PPages.selectProductPageUi,
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.people),
                      title: Text("Customer", style: PTextStyles.labelSmall),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet first
                        _showAddContactDialog(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.savings_outlined),
                      title: Text(
                        "Subscription",
                        style: PTextStyles.labelSmall,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(
                          context,
                          PPages.selectSubscriptionTypePageUi,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,

      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: provider.currentindex == 3 ? -1 : provider.currentindex,
        backgroundColor: PColors.darkGray,
        activeColor: PColors.red,
        inactiveColor: PColors.white,
        gapLocation: GapLocation.end,
        notchSmoothness: NotchSmoothness.smoothEdge,
        onTap: (index) {
          provider.updateIndex(index);
        },
      ),
    );
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedProfession = '';

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ContactViewModel>(
          builder: (context, provider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: PColors.darkGray,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    "Add New Contact",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomTextFeild(
                          controller: nameController,
                          hintText: "Full Name",
                          filColor: PColors.mediumGray,
                        ),
                        SizeBoxH(12),
                        CustomTextFeild(
                          controller: phoneController,
                          hintText: "Phone Number",
                          filColor: PColors.mediumGray,
                          keyboardType: TextInputType.phone,
                        ),
                        SizeBoxH(12),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            hintText: "Select Profession",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            filled: true,
                            fillColor: PColors.mediumGray,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          dropdownColor: PColors.mediumGray,
                          value: selectedProfession.isEmpty
                              ? null
                              : selectedProfession,
                          items: provider.availableProfessions.map((
                            profession,
                          ) {
                            return DropdownMenuItem<String>(
                              value: profession,
                              child: Text(
                                profession,
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedProfession = value ?? '';
                            });
                          },
                        ),
                        if (provider.error != null) ...[
                          SizeBoxH(12),
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              provider.error!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        provider.clearError();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.addContact(
                                name: nameController.text,
                                phone: phoneController.text,
                                profession: selectedProfession,
                              );

                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Contact added successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColors.red,
                      ),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Add Contact",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
