import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Settings/constants/sized_box.dart';
import '../../../../Settings/constants/text_styles.dart';
import '../../../../Settings/utils/p_colors.dart';
import '../../../../Settings/utils/p_pages.dart';
import '../../../commom_widgets/custom_elevated_button.dart';
import '../../../commom_widgets/custom_text_feild.dart';
import '../../view_model/auth_view_model.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Account",
                style: getTextComfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: PColors.white,
                ),
              ),
              SizeBoxH(8),
              Text(
                "Please sign up to get started",
                style: getTextStyle(
                  fontSize: 14,
                  color: PColors.lightGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizeBoxH(40),

              Consumer<AuthViewModel>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      // Username Field
                      CustomTextFeild(
                        controller: provider.usernameController,
                        hintText: "Username",
                        // enabled: !provider.isLoading,
                      ),
                      SizeBoxH(12),
                      
                      // Email Field
                      CustomTextFeild(
                        controller: provider.emailController,
                        hintText: "Email Address",
                        keyboardType: TextInputType.emailAddress,
                        // enabled: !provider.isLoading,
                      ),
                      SizeBoxH(12),
                      
                      // Password Field
                      CustomTextFeild(
                        controller: provider.passwordController,
                        hintText: "Password",
                        obscureText: !provider.isPasswordVisible,
                        // enabled: !provider.isLoading,
                        suffixIcon: IconButton(
                          onPressed: provider.togglePasswordVisibility,
                          icon: Icon(
                            provider.isPasswordVisible 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                            color: PColors.lightGray,
                          ),
                        ),
                        sufixfn: () {
                          
                        },
                      ),
                      SizeBoxH(12),
                      
                      // Confirm Password Field
                      CustomTextFeild(
                        controller: provider.confirmPasswordController,
                        hintText: "Confirm Password",
                        obscureText: !provider.isConfirmPasswordVisible,
                        // enabled: !provider.isLoading,
                        suffixIcon: IconButton(
                          onPressed: provider.toggleConfirmPasswordVisibility,
                          icon: Icon(
                            provider.isConfirmPasswordVisible 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                            color: PColors.lightGray,
                          ),
                        ),
                        sufixfn: () {
                          
                        },
                      ),

                      // Error Message
                      if (provider.error != null) ...[
                        SizeBoxH(12),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],

                      SizeBoxH(20),
                      
                      // Sign Up Button
                      CustomElavatedTextButton(
                        text: provider.isLoading ? "Creating Account..." : "Sign Up",
                        onPressed: provider.isLoading 
                            ? () {}
                            : () async {
                                final success = await provider.signUp();
                                if (success) {
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    PPages.wrapperPageUi,
                                    (route) => false,
                                  );
                                }
                              },
                      ),
                      
                      SizeBoxH(12),
                      
                      // Sign In Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: getTextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: PColors.white,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.clearError();
                              Navigator.pushReplacementNamed(context, PPages.login);
                            },
                            child: Text(
                              "Sign In",
                              style: getTextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: PColors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),

              SizeBoxH(40),
            ],
          ),
        ),
      ),
    );
  }
}