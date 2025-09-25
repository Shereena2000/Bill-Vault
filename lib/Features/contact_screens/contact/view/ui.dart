import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../commom_widgets/custom_appbar.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../model/contact_model.dart';
import '../view_model/contact_view_model.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactViewModel>().startListening();
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
      appBar: CustomAppBar(title: "Contacts"),
      body: Consumer<ContactViewModel>(
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
                  // Search Field
                  if (provider.hasContacts) ...[
                    CustomTextFeild(
                      controller: _searchController,
                      prefixIcon: Icon(Icons.search),
                      prefixfn: () {},
                      hintText: "Search contacts...",
                      filColor: PColors.darkGray,
                     onChanged: (value) => provider.searchContacts(value??''),
                    ),
                    SizeBoxH(18),
                  ],

                  // Content based on state
                  if (!provider.hasContacts)
                    _buildEmptyState(context)
                  else
                    _buildContactsList(provider),
                ],
              ),
            ),
          );}
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
            onPressed: () => _showAddContactDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactsList(ContactViewModel provider) {
    return Column(
      children: [
        // Results info
        if (provider.searchQuery.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: PColors.darkGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Found ${provider.contacts.length} contact${provider.contacts.length == 1 ? '' : 's'} for "${provider.searchQuery}"',
              style: PTextStyles.bodySmall,
            ),
          ),
          SizeBoxH(16),
        ],

        // Contacts list
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: provider.contacts.length,
          separatorBuilder: (context, index) => SizeBoxH(12),
          itemBuilder: (context, index) {
            final contact = provider.contacts[index];
            return _buildContactTile(context, contact, provider);
          },
        ),
      ],
    );
  }

  Widget _buildContactTile(BuildContext context, ContactModel contact, ContactViewModel provider) {
    return Container(
      decoration: BoxDecoration(
        color: PColors.darkGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: PColors.red,
          child: Text(
            contact.initials,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          contact.name,
          style: PTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.profession,
              style: PTextStyles.bodySmall.copyWith(color: Colors.grey[400]),
            ),
            SizeBoxH(2),
            Row(
              children: [
                Icon(Icons.phone, size: 14, color: Colors.grey[400]),
                SizeBoxV(4),
                Text(
                  contact.phone,
                  style: PTextStyles.bodySmall.copyWith(color: Colors.grey[300]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
          onSelected: (value) {
            switch (value) {
              case 'call':
                _makePhoneCall(contact.phone);
                break;
              case 'edit':
                _showEditContactDialog(context, contact);
                break;
              case 'delete':
                _showDeleteConfirmation(context, contact, provider);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'call',
              child: Row(
                children: [
                  Icon(Icons.phone, size: 18),
                  SizeBoxV(8),
                  Text('Call'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizeBoxV(8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 18, color: Colors.red),
                  SizeBoxV(8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text("Add New Contact", style: TextStyle(color: Colors.white)),
                  content: Column(
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
                        value: selectedProfession.isEmpty ? null : selectedProfession,
                        items: provider.availableProfessions.map((profession) {
                          return DropdownMenuItem<String>(
                            value: profession,
                            child: Text(profession, style: TextStyle(color: Colors.white)),
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
                  actions: [
                    TextButton(
                      onPressed: () {
                        provider.clearError();
                        Navigator.pop(context);
                      },
                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
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
                                    content: Text('Contact added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: PColors.red),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text("Add Contact", style: TextStyle(color: Colors.white)),
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

  void _showEditContactDialog(BuildContext context, ContactModel contact) {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController(text: contact.phone);
    String selectedProfession = contact.profession;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer<ContactViewModel>(
          builder: (context, provider, child) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  backgroundColor: PColors.darkGray,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  title: Text("Edit Contact", style: TextStyle(color: Colors.white)),
                  content: Column(
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
                        value: selectedProfession,
                        items: provider.availableProfessions.map((profession) {
                          return DropdownMenuItem<String>(
                            value: profession,
                            child: Text(profession, style: TextStyle(color: Colors.white)),
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
                  actions: [
                    TextButton(
                      onPressed: () {
                        provider.clearError();
                        Navigator.pop(context);
                      },
                      child: Text("Cancel", style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.updateContact(
                                id: contact.id!,
                                name: nameController.text,
                                phone: phoneController.text,
                                profession: selectedProfession,
                              );
                              
                              if (success) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Contact updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: PColors.red),
                      child: provider.isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text("Update Contact", style: TextStyle(color: Colors.white)),
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

  void _showDeleteConfirmation(BuildContext context, ContactModel contact, ContactViewModel provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: PColors.darkGray,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text("Delete Contact", style: TextStyle(color: Colors.white)),
          content: Text(
            "Are you sure you want to delete ${contact.name}? This action cannot be undone.",
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
                final success = await provider.deleteContact(contact.id!);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contact deleted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete contact'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch phone dialer'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error making phone call: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}