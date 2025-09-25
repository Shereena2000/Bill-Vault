// Create this as: lib/Features/subscription_screens/view/subscription_registration_date_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../subscriptions/model/subscription_data.dart';
import '../view_model/subscription_reg_view_model.dart';
import 'widget/sub_calender_widget.dart';

class SubscriptionRegistrationDateScreen extends StatefulWidget {
  const SubscriptionRegistrationDateScreen({super.key});

  @override
  State<SubscriptionRegistrationDateScreen> createState() => _SubscriptionRegistrationDateScreenState();
}

class _SubscriptionRegistrationDateScreenState extends State<SubscriptionRegistrationDateScreen> {
  SubscriptionData? subscriptionData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    print('SubscriptionRegistrationDateScreen - didChangeDependencies called');
    
    // Extract arguments and create SubscriptionData
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    print('Arguments received: $args');
    
    if (args != null && subscriptionData == null) {
      final subscriptionType = args['subscriptionType'] as String?;
      final subscriptionName = args['subscriptionName'] as String?;
      final brand = args['brand'] as String?;
      
      print('Extracted: subscriptionType=$subscriptionType, subscriptionName=$subscriptionName, brand=$brand');
      
      if (subscriptionType != null && subscriptionName != null && brand != null) {
        subscriptionData = SubscriptionData(
          subscriptionType: subscriptionType,
          subscriptionName: subscriptionName,
          brand: brand,
          registrationDate: DateTime.now(),
        );
        
        print('SubscriptionData created: $subscriptionData');
        
        // Set initial data in the provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('Setting subscription details in provider');
          context.read<SubscriptionRegistrationDateViewModel>().setSubscriptionDetails(
            subscriptionType, subscriptionName, brand
          );
        });
      } else {
        print('ERROR: Missing required subscription information');
      }
    } else if (subscriptionData != null) {
      print('SubscriptionData already exists: $subscriptionData');
    } else {
      print('No arguments received or subscriptionData is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SubscriptionRegistrationDateScreen - build called');
    
    return Scaffold(
      appBar: CustomAppBar(title: "Registration Date"),
      body: Consumer<SubscriptionRegistrationDateViewModel>(
        builder: (context, provider, child) {
          print('Consumer builder called - isLoading: ${provider.isLoading}');
          
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
        
                Text(
                  "Select Your Registration Date",
                  style: PTextStyles.headlineMedium,
                ),
                SizeBoxH(16),
                SubscriptionCalendarWidget(),
                
                if (provider.error != null) ...[
                  SizeBoxH(16),
                  Container(
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
                
                Spacer(),
                
             
                
                SizeBoxH(8),
                
                CustomElavatedTextButton(
                  text: "Continue",
                  onPressed: (subscriptionData != null) ? () {
                    print('=== CONTINUE BUTTON PRESSED ===');
                    
                    // Create updated SubscriptionData from provider data
                    final updatedSubscriptionData = subscriptionData!.copyWith(
                      registrationDate: provider.registrationDate,
                    );
                    
                    print('Updated SubscriptionData: $updatedSubscriptionData');
                    
                    try {
                      // Navigate to recurring period screen with SubscriptionData
                      Navigator.pushNamed(
                        context, 
                        PPages.selectSubscriptionRecurringPeriodPageUi,
                        arguments: updatedSubscriptionData,
                      );
                      print('Navigation completed');
                    } catch (e) {
                      print('Navigation error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Navigation error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } : null,
                ),
                SizeBoxH(16),
              ],
            ),
          );
        },
      ),
    );
  }
}