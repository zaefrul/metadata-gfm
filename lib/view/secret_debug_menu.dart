import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GEMS/utils/reference.dart';
import 'package:GEMS/view/debug_log_screen.dart';
import 'package:GEMS/controller/ReturnItem/api_test_screen.dart';

/// Secret Debug Menu - Accessed by tapping version number 10 times
class SecretDebugMenu extends StatelessWidget {
  static const String routeName = '/secret-debug-menu';

  const SecretDebugMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDefault,
      appBar: AppBar(
        title: Text(
          '🔧 Developer Menu',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepOrange.shade200),
            ),
            child: Column(
              children: [
                Icon(Icons.bug_report, size: 48, color: Colors.deepOrange),
                const SizedBox(height: 8),
                Text(
                  'Developer Tools',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'For debugging and testing only',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Debug Tools Section
          _buildSectionHeader('Debug Tools'),
          const SizedBox(height: 12),
          
          _buildDebugCard(
            context,
            icon: Icons.science_outlined,
            title: 'API Test',
            subtitle: 'Test Return Items API with current session',
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ApiTestScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          
          _buildDebugCard(
            context,
            icon: Icons.terminal,
            title: 'Debug Logs',
            subtitle: 'View app console logs and errors',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, DebugLogScreen.routeName);
            },
          ),
          const SizedBox(height: 24),

          // Information Section
          _buildSectionHeader('Information'),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.security,
            title: 'Secret Access',
            subtitle: 'Tap version number 10 times to access this menu',
          ),
          const SizedBox(height: 12),
          
          _buildInfoCard(
            icon: Icons.warning_amber_rounded,
            title: 'For Development Only',
            subtitle: 'Do not use these tools in production',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDebugCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 1,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
