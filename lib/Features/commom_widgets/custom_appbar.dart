import 'package:bill_vault/Settings/utils/p_colors.dart';
import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/view_model/auth_view_model.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: PTextStyles.displaySmall),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            final shouldLogout = await _showLogoutDialog(context);
            if (shouldLogout == true) {
              final authViewModel =
                  Provider.of<AuthViewModel>(context, listen: false);
              final success = await authViewModel.signOut();
              if (success && context.mounted) {
                // Navigate to login screen after logout
                Navigator.pushReplacementNamed(context, "/login");
              }
            }
          },
        ),
      ],
    );
  }

  // Logout confirmation dialog
  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: PColors.darkGray,
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
