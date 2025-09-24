import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../view_model/select_view_model.dart';
import 'widgets/product_card.dart';

class SelectProductScreen extends StatefulWidget {
  const SelectProductScreen({super.key});

  @override
  State<SelectProductScreen> createState() => _SelectProductScreenState();
}

class _SelectProductScreenState extends State<SelectProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelectProductViewModel>().loadProductTypes();
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
      appBar: CustomAppBar(title: "Select Product"),
      body: Consumer<SelectProductViewModel>(
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
                    onPressed: () => provider.loadProductTypes(),
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
                CustomTextFeild(
                  controller: _searchController,
                  prefixIcon: Icon(Icons.search),
                  prefixfn: () {},
                  hintText: "Search",
                  filColor: PColors.darkGray,
            //      onChanged: (value) => provider.searchProductTypes(value),
                ),
                SizeBoxH(18),
                Expanded(
                  child: GridView.builder(
                    itemCount: provider.productTypes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final productType = provider.productTypes[index];
                      return ProductsCard(
                        image: productType.imageUrl,
                        title: productType.name,
                        productType: productType,
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