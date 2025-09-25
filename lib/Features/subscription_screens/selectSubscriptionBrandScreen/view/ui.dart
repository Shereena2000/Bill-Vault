
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../view_model/sub_brand_view_model.dart';
import 'widgets/subscription_brand_card.dart';

class SelectSubscriptionBrandScreen extends StatefulWidget {
  final String subscriptionType;
  
  const SelectSubscriptionBrandScreen({super.key, required this.subscriptionType});

  @override
  State<SelectSubscriptionBrandScreen> createState() => _SelectSubscriptionBrandScreenState();
}

class _SelectSubscriptionBrandScreenState extends State<SelectSubscriptionBrandScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelectSubscriptionBrandViewModel>().setSubscriptionType(widget.subscriptionType);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Select ${widget.subscriptionType} Brand"),
      body: Consumer<SelectSubscriptionBrandViewModel>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.loadBrands(),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
            
                Expanded(
                  child: GridView.builder(
                    itemCount: provider.brands.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      final brand = provider.brands[index];
                      return SubscriptionBrandCard(
                        title: brand,
                        subscriptionType: widget.subscriptionType,
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            PPages.subscriptionRegistrationDatePageUi,
                            arguments: {
                              'subscriptionType': widget.subscriptionType,
                              'subscriptionName': widget.subscriptionType,
                              'brand': brand,
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}