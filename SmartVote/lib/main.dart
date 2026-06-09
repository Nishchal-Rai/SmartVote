
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartvote/providers/auth_provider.dart';
import 'package:smartvote/providers/election_provider.dart';
import 'package:smartvote/screens/auth/login_screen.dart';
import 'package:smartvote/screens/auth/register_screen.dart';
import 'package:smartvote/screens/splash_screen.dart';

import 'screens/elections/home_screen.dart';

void main() {
  runApp(const SmartVoteApp());
}

class SmartVoteApp extends StatelessWidget {
  const SmartVoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ElectionProvider()),
      ],
      child: MaterialApp(
        title: 'SmartVote',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3D35C8),
            secondary: Color(0xFFFF6B4A),
            surface: Color(0xFFFFFFFF),
            onPrimary: Colors.white,
            onSurface: Color(0xFF1A1A2E),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF3D35C8),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
