import 'package:bill_vault/Settings/utils/p_text_styles.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: PTextStyles.displaySmall),
      centerTitle: false,
      actions: actions,
    );
  }

  // 👇 important for AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
