import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'features/chat/presentation/cubit/chat_cubit.dart';

Future<void> main() async {
  // Ensure plugins are initialized properly
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ChatCubit>(
          create: (_) => ChatCubit(),
        ),
      ],
      child: MaterialApp(
        title: 'Chat App',
        theme: AppTheme.appTheme,
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter().generateRoute,
      ),
    );
  }
}