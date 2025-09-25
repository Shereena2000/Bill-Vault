
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../subscriptions/model/subscription_data.dart';
import '../view_model.dart/sub_reccurring_period_view_model.dart';

class SelectSubscriptionRecurringPeriodScreen extends StatefulWidget {
  const SelectSubscriptionRecurringPeriodScreen({super.key});

  @override
  State<SelectSubscriptionRecurringPeriodScreen> createState() => _SelectSubscriptionRecurringPeriodScreenState();
}

class _SelectSubscriptionRecurringPeriodScreenState extends State<SelectSubscriptionRecurringPeriodScreen> {
  SubscriptionData? subscriptionData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Extract SubscriptionData from arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    
    if (args is SubscriptionData && subscriptionData == null) {
      subscriptionData = args;
      print('SubscriptionData received in recurring period screen: $subscriptionData');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Select Recurring Period"),
      body: Consumer<SelectSubscriptionRecurringPeriodViewModel>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Saving subscription...'),
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
                    itemCount: provider.recurringPeriods.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemBuilder: (context, index) {
                      final period = provider.recurringPeriods[index];
                      final isSelected = provider.selectedRecurringPeriod == period;
                      
                      return GestureDetector(
                        onTap: () => provider.selectRecurringPeriod(period),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? PColors.red : PColors.darkGray,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? PColors.red : PColors.mediumGray,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              period,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                if (provider.error != null) ...[
                  Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: provider.clearError,
                          child: Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ],
                
                CustomElavatedTextButton(
                  text: provider.hasSelection ? "SAVE SUBSCRIPTION" : "SELECT PERIOD",
                  onPressed: provider.hasSelection && subscriptionData != null
                      ? () async {
                          final success = await provider.saveSubscription(subscriptionData!);
                          if (success) {
                            provider.clearSelection();
                            
                            // Navigate back to subscription list
                            Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            );
                            
                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Subscription saved successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      : null,
                ),
                SizeBoxH(8),
              ],
            ),
          );
        },
      ),
    );
  }
}