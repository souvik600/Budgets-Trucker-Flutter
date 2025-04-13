import 'package:flutter/material.dart';
import 'package:mass_manager/core/constants/strings.dart';
import 'package:mass_manager/core/constants/styles.dart';
import 'package:mass_manager/core/utils/validators.dart';

class AuthForm extends StatelessWidget {
  final bool isLogin;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController? nameController;
  final TextEditingController? phoneController;
  final VoidCallback onSubmit;
  final bool isLoading;

  const AuthForm({
    super.key,
    required this.isLogin,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    this.nameController,
    this.phoneController,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          if (!isLogin) ...[
            TextFormField(
              controller: nameController,
              decoration: AppStyles.inputDecoration(
                AppStrings.name,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: Validators.validateName,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              decoration: AppStyles.inputDecoration(
                AppStrings.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
          ],
          TextFormField(
            controller: emailController,
            decoration: AppStyles.inputDecoration(
              AppStrings.email,
              prefixIcon: const Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            decoration: AppStyles.inputDecoration(
              AppStrings.password,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            validator: Validators.validatePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          if (isLogin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Implement forgot password
                },
                child: const Text(AppStrings.forgotPassword),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              child: isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(isLogin ? AppStrings.signIn : AppStrings.signUp),
            ),
          ),
        ],
      ),
    );
  }
}