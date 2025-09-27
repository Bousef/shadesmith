import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6B46C1), // Purple
              Color(0xFF4C51BF), // Indigo
              Color(0xFF3182CE), // Blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Welcome section
                Consumer<AppAuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // ShadeSmith Logo
                        ClipRect(
                          child: Image.asset(
                            'assets/images/ShadeSmithTransparentLogo.png',
                            height: 120,
                            fit: BoxFit.fitHeight,
                            filterQuality: FilterQuality.high,
                            isAntiAlias: true,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Welcome to ShadeSmith!',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hello, ${authProvider.user?.displayName ?? authProvider.user?.email ?? 'User'}!',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),

                // User info card
                Consumer<AppAuthProvider>(
                  builder: (context, authProvider, child) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Information',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Email',
                            authProvider.user?.email ?? 'Not available',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Display Name',
                            authProvider.user?.displayName ?? 'Not set',
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'User ID',
                            authProvider.user?.uid ?? 'Not available',
                          ),
                          if (authProvider.user?.photoURL != null) ...[
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  'Profile Photo: ',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                ClipOval(
                                  child: Image.network(
                                    authProvider.user!.photoURL!,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Sign out button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEF4444), // Red
                        Color(0xFFDC2626), // Darker red
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await context.read<AppAuthProvider>().signOut();
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
