import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Settings',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('General'),
                _buildListTile(
                  icon: Icons.payment_rounded,
                  title: 'Payment Methods',
                  subtitle: '3 cards saved'),
                _buildListTile(
                    icon: Icons.history_rounded,
                    title: 'Ride History',
                    subtitle: '12 completed rides'),
                _buildSectionHeader('Preferences'),
                _buildListTile(
                    icon: Icons.dark_mode_rounded, title: 'Dark Mode', isSwitch: true),
                _buildListTile(
                    icon: Icons.notifications_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage alerts'),
                _buildSectionHeader('Support'),
                _buildListTile(
                    icon: Icons.help_center_rounded,
                    title: 'Help Center',
                    subtitle: 'FAQs & support'),
                _buildListTile(
                    icon: Icons.security_rounded,
                    title: 'Privacy & Security',
                    subtitle: 'Data protection'),
                _buildListTile(
                    icon: Icons.info_rounded,
                    title: 'About App',
                    subtitle: 'Version 2.3.1'),
                const SizedBox(height: 20),
                _buildLogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text('S',
                  style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Shotayo Adeleke',
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const SizedBox(height: 4),
                Text('shotayo@example.com',
                    style: GoogleFonts.poppins(
                        color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: Text('Edit Profile',
                      style: GoogleFonts.poppins(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    backgroundColor: Colors.blue[50],
                  ),
                  onPressed: () {},
                )
              ]),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600])),
    );
  }

  Widget _buildListTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      bool isSwitch = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue[800], size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.grey))
            : null,
        trailing: isSwitch
            ? Switch(
                value: true,
                activeColor: Colors.blue[800],
                onChanged: (value) {})
            : Icon(Icons.chevron_right_rounded,
                color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        visualDensity: const VisualDensity(vertical: -2),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.logout_rounded, size: 18),
          const SizedBox(width: 8),
          Text('Log Out',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
      onPressed: () {},
    );
  }
}