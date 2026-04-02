import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/advisory_model.dart';
import 'advisory_floating_card.dart';

/// 🌿 GLOBAL GREEN GRADIENT
const LinearGradient kGreenGradient = LinearGradient(
  colors: [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF66BB6A),
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ReadAdvisoryScreen extends StatelessWidget {
  const ReadAdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kGreenGradient),
        ),
        title: const Text('Crop Advisories'),
      ),
      body: Column(
        children: [
          _filterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('advisories')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No advisories available'),
                  );
                }

                final advisories = snapshot.data!.docs
                    .map((doc) => Advisory.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: advisories.length,
                  itemBuilder: (context, index) {
                    return _advisoryCard(
                        context, advisories[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 FILTER CHIPS (UI ONLY FOR NOW)
  Widget _filterSection() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          _FilterChip(label: 'All'),
          _FilterChip(label: 'Pest'),
          _FilterChip(label: 'Weather'),
          _FilterChip(label: 'Disease'),
          _FilterChip(label: 'Fertilizer'),
        ],
      ),
    );
  }

  // 📰 ADVISORY CARD
  Widget _advisoryCard(BuildContext context, Advisory advisory) {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Advisory',
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) {
            return AdvisoryFloatingCard(advisory: advisory);
          },
          transitionBuilder: (_, animation, __, child) {
            final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: curved,
                child: child,
              ),
            );
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼 CLOUDINARY IMAGE
            if (advisory.image.isNotEmpty)
          ClipRRect(
      borderRadius: const BorderRadius.vertical(
      top: Radius.circular(18),
    ),
    child: Image.network(
    advisory.image,
    height: 160,
    width: double.infinity,
    fit: BoxFit.cover,
    ),
    ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (advisory.isCritical) _criticalBadge(),

                  Text(
                    advisory.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Crop: ${advisory.crop}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    advisory.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        advisory.date,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Text(
                        'Read more →',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _criticalBadge() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.red.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'CRITICAL ALERT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// 🔘 FILTER CHIP
class _FilterChip extends StatelessWidget {
  final String label;
  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        backgroundColor: Colors.green.shade50,
      ),
    );
  }
}
