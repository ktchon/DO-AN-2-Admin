import 'package:flutter/material.dart';
import 'package:kc_admin_panel/data/repositories/authentication/auth_repository.dart';

class LoginController with ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthRepository _repository = AuthRepository();

  bool _rememberMe = false;
  bool _isObscurePassword = true;
  bool _isLoading = false;

  bool get rememberMe => _rememberMe;
  bool get isObscurePassword => _isObscurePassword;
  bool get isLoading => _isLoading;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isObscurePassword = !_isObscurePassword;
    notifyListeners();
  }

  Future<void> signIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Vui lòng nhập email và mật khẩu');
      return;
    }

    _isLoading = true;
    notifyListeners();

    final result = await _repository.loginAdmin(
      email: email,
      password: password,
    );

    _isLoading = false;
    notifyListeners();

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showSnackBar(context, result['message']);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}