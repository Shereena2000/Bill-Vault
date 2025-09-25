
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../../Settings/utils/p_text_styles.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../view_model/subscriotions_view_model.dart';
import 'widgets/subscription_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionViewModel>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Subscriptions"),
      body: Consumer<SubscriptionViewModel>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${provider.error}',
                    style: PTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.clearError();
                      provider.startListening();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (!provider.hasSubscriptions)
                    _buildEmptyState(context)
                  else
                    _buildSubscriptionsList(provider),
                ],
              ),
            ),
          );
        },
      ),
  
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height - 200,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Track your subscriptions easily",
            style: PTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),
          SizeBoxH(16),
          Text(
            "No subscriptions added yet",
            style: PTextStyles.bodyLarge,
          ),
          SizeBoxH(12),
          CustomElavatedTextButton(
            width: 180,
            height: 40,
            text: "Add Subscription",
            onPressed: () {
              Navigator.pushNamed(context, PPages.selectSubscriptionTypePageUi);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(SubscriptionViewModel provider) {
    return Column(
      children: [
        // Header with count
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PColors.darkGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Subscriptions',
                style: PTextStyles.headlineMedium,
              ),
              SizeBoxH(4),
              Text(
                '${provider.subscriptions.length} active subscription${provider.subscriptions.length == 1 ? '' : 's'}',
                style: PTextStyles.bodyMedium.copyWith(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
        
        SizeBoxH(16),
        
        // Subscriptions list
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.subscriptions.length,
          separatorBuilder: (context, index) => SizeBoxH(16),
          itemBuilder: (context, index) {
            final subscription = provider.subscriptions[index];
            return SubscriptionCard(
              subscription: subscription,
              onDelete: () => _showDeleteConfirmation(context, subscription, provider),
            );
          },
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, subscription, SubscriptionViewModel provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PColors.darkGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Delete Subscription", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete ${subscription.subscriptionName}?",
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                final success = await provider.deleteSubscription(subscription.id!);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subscription deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}