import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../../../commom_widgets/branditem_card.dart';
import '../view_model/select_view_model.dart';

class SelectBrandScreen extends StatefulWidget {
  final String productType;
  
  const SelectBrandScreen({super.key, required this.productType});

  @override
  State<SelectBrandScreen> createState() => _SelectBrandScreenState();
}

class _SelectBrandScreenState extends State<SelectBrandScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelectBrandViewModel>().setProductType(widget.productType);
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
      appBar: CustomAppBar(title: "Select Brand"),
      body: Consumer<SelectBrandViewModel>(
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
                CustomTextFeild(
                  controller: _searchController,
                  prefixIcon: Icon(Icons.search),
                  prefixfn: () {},
                  hintText: "Search",
                  filColor: PColors.darkGray,

                onChanged: (value) => provider.searchBrands(value??''),
                ),
                SizeBoxH(18),
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
                      return BrandItemCard(
                        title: brand,
                        productType: widget.productType,
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