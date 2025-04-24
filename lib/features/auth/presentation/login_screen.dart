import 'package:flutter/material.dart';
import 'package:b_connect_task/core/constants/app_colors.dart';
import 'package:b_connect_task/core/router/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:b_connect_task/core/components/app_logo.dart';
import 'package:b_connect_task/core/components/custom_button.dart';
import 'package:b_connect_task/core/components/custom_error_widget.dart';
import 'package:b_connect_task/core/components/custom_password_field.dart';
import 'package:b_connect_task/core/components/custom_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'البريد الإلكتروني غير موجود';
            break;
          case 'wrong-password':
            _errorMessage = 'كلمة المرور غير صحيحة';
            break;
          case 'invalid-email':
            _errorMessage = 'البريد الإلكتروني غير صالح';
            break;
          default:
            _errorMessage = 'حدث خطأ في تسجيل الدخول';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في تسجيل الدخول';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                AppLogo(height: 120.h, width: 120.w),
                SizedBox(height: 40.h),
                Text(
                  'تسجيل الدخول',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.main,
                    fontFamily: 'Cairo',
                    fontSize: 19.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30.h),
                CustomTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  labelText: 'البريد الإلكتروني',
                  hintText: 'أدخل البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email, size: 20.w),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'الرجاء إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.h),
                CustomPasswordField(
                  controller: _passwordController,
                  labelText: 'كلمة المرور',
                  hintText: 'أدخل كلمة المرور',
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                    },
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                if (_errorMessage != null)
                  CustomErrorWidget(errorMessage: _errorMessage!),
                SizedBox(height: 20.h),
                CustomButton(
                  text: 'تسجيل الدخول',
                  onPressed: _login,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.main,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ليس لديك حساب؟',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.signUp);
                      },
                      child: Text(
                        'إنشاء حساب',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.main,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}