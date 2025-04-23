import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:b_connect_task/core/router/routes.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/chat/presentation/chat_home_page.dart';
import '../../features/splash/presentation/splash_screen.dart';

class AppRouter {
  static const int fadeDuration = 400;

  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return _getFadeTransition(const SplashScreen());
      case Routes.login:
        return _getFadeTransition(const LoginScreen());
      case Routes.signUp:
        return _getFadeTransition(const RegisterScreen());
      case Routes.home:
        return _getFadeTransition(const ChatHomePage());
      
      // Add more routes as needed
      
      default:
        return _getFadeTransition(const SplashScreen()); // Default route
    }
  }

  Route _getFadeTransition(Widget child) {
    if (Platform.isIOS) {
      return MaterialPageRoute(
        builder: (_) => child,
      );
    } else {
      return PageTransition(
        child: child,
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: fadeDuration),
      );
    }
  }
}