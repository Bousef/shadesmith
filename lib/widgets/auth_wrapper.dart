import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_auth_provider.dart';
import '../screens/landing_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
        return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading && authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
              ),
            ),
          );
        }

        // If user is signed in, show home screen
        if (authProvider.isSignedIn) {
          return const HomeScreen();
        }

        // If user is not signed in, show landing screen
        return const LandingScreen();
      },
    );
  }
}
