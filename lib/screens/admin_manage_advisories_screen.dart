import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advisory_model.dart';
import 'admin_add_advisory_screen.dart';

/// 🔵 ADMIN BLUE GRADIENT
const LinearGradient kBlueGradient = LinearGradient(
  colors: [
    Color(0xFF0D47A1),
    Color(0xFF1565C0),
    Color(0xFF42A5F5),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class AdminManageAdvisoriesScreen extends StatelessWidget {
  const AdminManageAdvisoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text('Manage Advisories'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kBlueGradient),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('advisories')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No advisories found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final adv = Advisory.fromJson(
                docs[index].id,
                docs[index].data() as Map<String, dynamic>,
              );
              return _advisoryCard(context, adv);
            },
          );
        },
      ),
    );
  }

  /// 📰 ADVISORY CARD
  Widget _advisoryCard(BuildContext context, Advisory adv) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🖼 IMAGE PREVIEW (Cloudinary compatible)
          if (adv.image.isNotEmpty)
            ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(18)),
              child: Image.network(
                adv.image,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// TITLE + CRITICAL BADGE
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        adv.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (adv.isCritical)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'CRITICAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  'Crop: ${adv.crop}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),

                const SizedBox(height: 8),

                Text(
                  adv.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                /// ACTION BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon:
                      const Icon(Icons.edit, color: Colors.blue),
                      label: const Text('Edit'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminAddAdvisoryScreen(advisory: adv),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon:
                      const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete'),
                      onPressed: () =>
                          _confirmDelete(context, adv.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ DELETE CONFIRMATION
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Advisory'),
        content: const Text(
          'Are you sure you want to delete this advisory?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('advisories')
                  .doc(id)
                  .delete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
