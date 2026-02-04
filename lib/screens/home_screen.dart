import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'stage_selection_screen.dart';
import 'auth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background "PLAY" Text
          Positioned(
            top: -50,
            left: -20,
            right: 0,
            child: Text(
              'PLAY',
              style: GoogleFonts.outfit(
                fontSize: 200,
                fontWeight: FontWeight.w900,
                color: Colors.white.withOpacity(0.03),
                height: 1,
              ),
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Play Chess',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.menu),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white10,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Game Modes (Bento Grid)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      SizedBox(
                        height: 320,
                        child: Row(
                          children: [
                            // Compete Online (Tall Card)
                            Expanded(
                              flex: 5,
                              child: _buildGradientCard(
                                context,
                                title: 'Compete\nonline',
                                subtitle: 'against another player',
                                gradient: AppTheme.purpleGradient,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AuthScreen(isSignUp: false)),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Right Column
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  // Play with friends
                                  Expanded(
                                    child: _buildGlassCard(
                                      context,
                                      title: 'Play with\nyour friends',
                                      icon: Icons.people_outline,
                                      avatars: true,
                                      onTap: () {
                                         Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const AuthScreen(isSignUp: true)),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Play against computer
                                  Expanded(
                                    child: _buildGlassCard(
                                      context,
                                      title: 'Play against\ncomputer',
                                      icon: Icons.computer,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const StageSelectionScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Learn More Section
                      Text(
                        'Learn more',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        height: 180, // Allow space for options
                        child: Column(
                            children: [
                                _buildWideOption(context, 'Start lessons', Icons.school_outlined),
                                const SizedBox(height: 12),
                                _buildWideOption(context, 'Open puzzles', Icons.extension_outlined),
                                const SizedBox(height: 12),
                                _buildWideOption(context, 'Chess events', Icons.emoji_events_outlined),
                            ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientCard(BuildContext context,
      {required String title, required String subtitle, required Gradient gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
            
            Row(
                children: [
                     Expanded(
                         child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                     ),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context,
      {required String title, required IconData icon, required VoidCallback onTap, bool avatars = false}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Flexible(
                        child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Colors.white,
                        ),
                        ),
                     ),
                  ],
                ),
                if (avatars)
                   SizedBox(
                       height: 30,
                       width: 60,
                       child: Stack(
                           children: [
                               Positioned(left: 0, child: CircleAvatar(backgroundColor: Colors.red, radius: 12, child: Text("A", style: TextStyle(fontSize: 10)))),
                               Positioned(left: 15, child: CircleAvatar(backgroundColor: Colors.blue, radius: 12, child: Text("B", style: TextStyle(fontSize: 10)))),
                               Positioned(left: 30, child: CircleAvatar(backgroundColor: Colors.green, radius: 12, child: Text("C", style: TextStyle(fontSize: 10)))),
                           ],
                       ),
                   )
                else
                   Align(
                       alignment: Alignment.bottomRight,
                       child: Icon(icon, color: Colors.white70, size: 28),
                   ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildWideOption(BuildContext context, String title, IconData icon) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              color: Colors.transparent,
          ),
          child: Row(
              children: [
                  Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: AppTheme.secondaryPink,
                          borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
          ),
      );
  }
}
