import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';

import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../../commom_widgets/custom_text_feild.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();
      final TextEditingController _nameController = TextEditingController();
  final TextEditingController _PhoneController = TextEditingController();
    return Scaffold(
      appBar: CustomAppBar(title: "Contacts"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // CustomTextFeild(
              //   controller: _searchController,
              //   prefixIcon: Icon(Icons.search),
              //   prefixfn: () {},
              //   hintText: "Search",
              //   filColor: PColors.darkGray,

              //   //  onChanged: (value) => provider.searchBrands(value),
              // ),
              // data is empty
              Container(
                height:
                    MediaQuery.of(context).size.height - 200, // Give it height
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Add your contact details to get started",
                      style: PTextStyles.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    SizeBoxH(16),
                    Text(
                      "Your Contact List is empty",
                      style: PTextStyles.bodyLarge,
                    ),
                    SizeBoxH(12),
                    CustomElavatedTextButton(
                      width: 180,
                      height: 40,
                      text: "Add New Contact",
                      onPressed: () {
                        _showDialog(context);
                      },
                    ),
                    SizeBoxH(20),

                    // Debug button
                  ],
                ),
              ),
              // SizeBoxH(18),

              // ListTile(
              //   tileColor: PColors.darkGray,
              //   leading: CircleAvatar(
              //     backgroundColor: PColors.red,
              //     child: Text("S"),
              //   ),
              //   title: Text("Shereena", style: PTextStyles.bodySmall),
              //   subtitle: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text("A C Technician", style: PTextStyles.bodySmall),
              //       Text("7592946170", style: PTextStyles.bodySmall),
              //     ],
              //   ),
              //   trailing: Icon(Icons.more_vert),//edit delete
              // ),
            ],
          ),
        ),
      ),
    );
  }
    void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            
          ),
          title: const Text("Enter Details"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             CustomTextFeild(hintText: "Name"),
              const SizedBox(height: 12),
                    CustomTextFeild(hintText: "Phone"),



                    //where add dropdown where list 
 //"A C Technicision",
             // //Builder,CCTV installer ,Drivrt,carpenter like that




            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text("Cancel",style: TextStyle(color: PColors.white),),
            ),
            ElevatedButton(
              onPressed: () {
          
                Navigator.pop(context);
              },
              child:  Text("Submit",style: TextStyle(color: PColors.white)),
            ),
          ],
        );
      },
    );
  }
}
