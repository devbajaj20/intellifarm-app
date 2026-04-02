import 'package:flutter/material.dart';
import 'admin_add_advisory_screen.dart';
import 'admin_manage_advisories_screen.dart';
import 'admin_crop_manager_screen.dart'; // NEW


const LinearGradient kBlueGradient = LinearGradient(
  colors: [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kBlueGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            'Add Advisory',
            Icons.campaign,
            const AdminAddAdvisoryScreen(),
          ),
          const SizedBox(height: 12),
          _tile(
            context,
            'Manage Advisories',
            Icons.edit_note,
            const AdminManageAdvisoriesScreen(),
          ),
          const SizedBox(height: 12),
          _tile(
            context,
            'Crop Manager',
            Icons.agriculture,
            const AdminCropManagerScreen(),
          ),

        ],
      ),
    );
  }

  Widget _tile(
      BuildContext context,
      String title,
      IconData icon,
      Widget page,
      ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade700),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }
}
