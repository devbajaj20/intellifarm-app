import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddCropScreen extends StatefulWidget {
  const AdminAddCropScreen({super.key});

  @override
  State<AdminAddCropScreen> createState() => _AdminAddCropScreenState();
}

/// 🔹 Internal stage form model
class _StageForm {
  final TextEditingController nameCtrl;
  final TextEditingController startCtrl;
  final TextEditingController endCtrl;

  _StageForm({
    required String name,
    required int start,
    required int end,
  })  : nameCtrl = TextEditingController(text: name),
        startCtrl = TextEditingController(text: start.toString()),
        endCtrl = TextEditingController(text: end.toString());
}

class _AdminAddCropScreenState extends State<AdminAddCropScreen> {
  final _nameController = TextEditingController();
  final _durationController = TextEditingController();

  String _category = 'cereals';

  /// ✅ CORRECT STAGE LIST
  final List<_StageForm> _stages = [];

  // ─────────────────────────────
  // STAGE ACTIONS
  // ─────────────────────────────
  void _addStage() {
    setState(() {
      _stages.add(_StageForm(name: '', start: 0, end: 0));
    });
  }

  void _removeStage(int index) {
    setState(() {
      _stages.removeAt(index);
    });
  }

  void _autoGenerateStages() {
    final total = int.tryParse(_durationController.text.trim());
    if (total == null || total <= 0) {
      _showError('Enter total duration first');
      return;
    }

    setState(() {
      _stages.clear();

      final g1 = (total * 0.1).round();
      final g2 = (total * 0.4).round();
      final g3 = (total * 0.3).round();

      _stages.addAll([
        _StageForm(name: 'Germination', start: 0, end: g1),
        _StageForm(name: 'Vegetative', start: g1 + 1, end: g1 + g2),
        _StageForm(
            name: 'Flowering',
            start: g1 + g2 + 1,
            end: g1 + g2 + g3),
        _StageForm(
            name: 'Harvest',
            start: g1 + g2 + g3 + 1,
            end: total),
      ]);
    });
  }

  // ─────────────────────────────
  // STAGE VALIDATION RULES
  // ─────────────────────────────
  bool _validateStages(
      List<Map<String, dynamic>> stages,
      int totalDuration,
      ) {
    stages.sort((a, b) => a['startDay'].compareTo(b['startDay']));

    if (stages.first['startDay'] != 0) {
      _showError('First stage must start at day 0');
      return false;
    }

    for (int i = 0; i < stages.length; i++) {
      final current = stages[i];

      if (current['endDay'] <= current['startDay']) {
        _showError('Invalid day range in "${current['name']}"');
        return false;
      }

      if (i > 0) {
        final prev = stages[i - 1];
        if (current['startDay'] != prev['endDay'] + 1) {
          _showError('Stages must be continuous (no gaps/overlap)');
          return false;
        }
      }
    }

    if (stages.last['endDay'] != totalDuration) {
      _showError(
        'Last stage must end at total duration ($totalDuration)',
      );
      return false;
    }

    return true;
  }

  // ─────────────────────────────
  // SAVE
  // ─────────────────────────────
  Future<void> _saveCrop() async {
    final name = _nameController.text.trim();
    final durationText = _durationController.text.trim();

    if (name.isEmpty || durationText.isEmpty) {
      _showError('Crop name and duration are required');
      return;
    }

    final totalDuration = int.tryParse(durationText);
    if (totalDuration == null || totalDuration <= 0) {
      _showError('Enter a valid total duration');
      return;
    }

    if (_stages.isEmpty) {
      _showError('Add at least one growth stage');
      return;
    }

    /// Build stages
    final List<Map<String, dynamic>> stagesData = [];

    for (final s in _stages) {
      final stageName = s.nameCtrl.text.trim();
      final start = int.tryParse(s.startCtrl.text) ?? -1;
      final end = int.tryParse(s.endCtrl.text) ?? -1;

      if (stageName.isEmpty) {
        _showError('Stage name cannot be empty');
        return;
      }
      if (start < 0 || end < 0) {
        _showError('Invalid stage day values');
        return;
      }

      stagesData.add({
        'name': stageName,
        'startDay': start,
        'endDay': end,
      });
    }

    /// 🔒 APPLY VALIDATION RULES
    if (!_validateStages(stagesData, totalDuration)) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('crops').add({
        'name': name,
        'category': _category,
        'totalDuration': totalDuration,
        'stages': stagesData,
        'isActive': true, // ✅ SOFT DELETE READY
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (_) {
      _showError('Failed to save crop');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─────────────────────────────
  // UI
  // ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Crop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Crop Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'cereals', child: Text('Cereals')),
                DropdownMenuItem(value: 'pulses', child: Text('Pulses')),
                DropdownMenuItem(value: 'fruits', child: Text('Fruits')),
                DropdownMenuItem(
                    value: 'vegetables', child: Text('Vegetables')),
              ],
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Total Duration (days)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _autoGenerateStages,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Auto Generate Stages'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Growth Stages',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addStage,
                ),
              ],
            ),
            ..._stages.asMap().entries.map((entry) {
              final i = entry.key;
              final stage = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Stage ${i + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red),
                            onPressed: () => _removeStage(i),
                          ),
                        ],
                      ),
                      TextField(
                        controller: stage.nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Stage Name'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stage.startCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'Start Day'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: stage.endCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: 'End Day'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveCrop,
                child: const Text(
                  'Save Crop',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
