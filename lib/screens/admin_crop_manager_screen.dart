import 'package:flutter/material.dart';
import 'admin_add_crop_screen.dart';
import 'admin_crop_list_screen.dart';

class AdminCropManagerScreen extends StatelessWidget {
  const AdminCropManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Manager'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            'Add Crop',
            Icons.add_circle_outline,
            const AdminAddCropScreen(),
          ),
          const SizedBox(height: 12),
          _tile(
            context,
            'Manage Crops',
            Icons.list_alt,
            const AdminCropListScreen(),
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
        leading: Icon(icon, color: Colors.green.shade700),
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
