
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../view_model/subscription_type_view_model.dart';
import '../widgets/subscription_type_card.dart';

class SelectSubscriptionTypeScreen extends StatefulWidget {
  const SelectSubscriptionTypeScreen({super.key});

  @override
  State<SelectSubscriptionTypeScreen> createState() => _SelectSubscriptionTypeScreenState();
}

class _SelectSubscriptionTypeScreenState extends State<SelectSubscriptionTypeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('SelectSubscriptionTypeScreen - initState called');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Loading subscription types...');
      context.read<SelectSubscriptionTypeViewModel>().loadSubscriptionTypes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('SelectSubscriptionTypeScreen - build called');
    
    return Scaffold(
      appBar: CustomAppBar(title: "Select Subscription Type"),
      body: Consumer<SelectSubscriptionTypeViewModel>(
        builder: (context, provider, child) {
          print('Consumer builder - isLoading: ${provider.isLoading}');
          print('Consumer builder - error: ${provider.error}');
          print('Consumer builder - subscription types count: ${provider.subscriptionTypes.length}');
          
          if (provider.isLoading) {
            print('Showing loading indicator');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading subscription types...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            print('Showing error: ${provider.error}');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Retry button pressed');
                      provider.loadSubscriptionTypes();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.subscriptionTypes.isEmpty) {
            print('No subscription types found');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No subscription types available'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      print('Reload button pressed');
                      provider.loadSubscriptionTypes();
                    },
                    child: Text('Reload'),
                  ),
                ],
              ),
            );
          }

          print('Showing subscription types grid with ${provider.subscriptionTypes.length} items');
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
               
                
           
               
                Expanded(
                  child: GridView.builder(
                    itemCount: provider.subscriptionTypes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final subscriptionType = provider.subscriptionTypes[index];
                      print('Building card for: ${subscriptionType.name}');
                      return SubscriptionTypeCard(
                        image: subscriptionType.imageUrl,
                        title: subscriptionType.name,
                        subscriptionType: subscriptionType,
                        onTap: () {
                          print('Subscription type selected: ${subscriptionType.name}');
                          Navigator.pushNamed(
                            context, 
                            PPages.selectSubscriptionBrandPageUi,
                            arguments: subscriptionType.name,
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