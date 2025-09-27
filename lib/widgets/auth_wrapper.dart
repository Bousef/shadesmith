import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_auth_provider.dart';
import '../screens/landing_screen.dart';
import '../screens/home_screen.dart';
import 'paint_transition.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _hasShownTransition = false;
  String? _lastUserId;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    // Force a delay to ensure we start with landing screen on fresh launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _hasInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppAuthProvider>(
      builder: (context, authProvider, child) {
        // Reset transition flag when user logs out or changes
        if (_lastUserId != null && authProvider.user?.uid != _lastUserId) {
          _hasShownTransition = false;
        }
        _lastUserId = authProvider.user?.uid;

        // Show loading screen while checking auth state on first load
        if (authProvider.isLoading || !_hasInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
              ),
            ),
          );
        }

        // If user is signed in and we haven't shown transition yet
        if (authProvider.isSignedIn && !_hasShownTransition) {
          return PaintTransition(
            onTransitionComplete: () {
              setState(() {
                _hasShownTransition = true;
              });
            },
            child: const HomeScreen(),
          );
        }

        // If user is signed in (after transition or subsequent loads)
        if (authProvider.isSignedIn) {
          return const HomeScreen();
        }

        // If user is not signed in, show landing screen
        return const LandingScreen();
      },
    );
  }
}
