import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditCropScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> cropData;

  const AdminEditCropScreen({
    super.key,
    required this.docId,
    required this.cropData,
  });

  @override
  State<AdminEditCropScreen> createState() => _AdminEditCropScreenState();
}

class _AdminEditCropScreenState extends State<AdminEditCropScreen> {
  late TextEditingController _nameController;
  late TextEditingController _durationController;

  late String _category;
  late List<Map<String, dynamic>> _stages;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.cropData['name']);
    _durationController = TextEditingController(
        text: widget.cropData['totalDuration'].toString());

    _category = widget.cropData['category'];
    _stages =
    List<Map<String, dynamic>>.from(widget.cropData['stages']);
  }

  Future<void> _updateCrop() async {
    await FirebaseFirestore.instance
        .collection('crops')
        .doc(widget.docId)
        .update({
      'name': _nameController.text.trim(),
      'category': _category,
      'totalDuration': int.parse(_durationController.text),
      'stages': _stages,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Crop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration:
              const InputDecoration(labelText: 'Crop Name'),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              items: const [
                DropdownMenuItem(value: 'cereals', child: Text('Cereals')),
                DropdownMenuItem(value: 'pulses', child: Text('Pulses')),
                DropdownMenuItem(value: 'fruits', child: Text('Fruits')),
                DropdownMenuItem(
                    value: 'vegetables', child: Text('Vegetables')),
              ],
              onChanged: (v) => setState(() => _category = v!),
              decoration:
              const InputDecoration(labelText: 'Category'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: 'Total Duration'),
            ),

            const SizedBox(height: 16),

            ..._stages.asMap().entries.map((entry) {
              final i = entry.key;
              final stage = entry.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextField(
                        decoration:
                        const InputDecoration(labelText: 'Stage Name'),
                        controller:
                        TextEditingController(text: stage['name']),
                        onChanged: (v) => stage['name'] = v,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: stage['startDay'].toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                              stage['startDay'] = int.parse(v),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: TextEditingController(
                                  text: stage['endDay'].toString()),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                              stage['endDay'] = int.parse(v),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _updateCrop,
              child: const Text('Update Crop'),
            ),
          ],
        ),
      ),
    );
  }
}
