import 'package:flutter/material.dart';
import '../models/advisory_model.dart';

class AdvisoryFloatingCard extends StatelessWidget {
  final Advisory advisory;

  const AdvisoryFloatingCard({
    super.key,
    required this.advisory,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 👆 Swipe down to close
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 14) {
          Navigator.pop(context);
        }
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ───────── DRAG INDICATOR ─────────
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 6),
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    // ───────── HERO IMAGE ─────────
                    Hero(
                      tag: advisory.id,
                      child: Image.network(
                        advisory.image,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔴 CRITICAL BADGE
                          if (advisory.isCritical)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'CRITICAL ALERT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // 📰 TITLE
                          Text(
                            advisory.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 📄 DESCRIPTION
                          Text(
                            advisory.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ❌ CLOSE BUTTON
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
