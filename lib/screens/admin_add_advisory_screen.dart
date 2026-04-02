import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cloudinary_service.dart';
import '../models/advisory_model.dart';

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

class AdminAddAdvisoryScreen extends StatefulWidget {
  final Advisory? advisory; // null = add, not null = edit

  const AdminAddAdvisoryScreen({super.key, this.advisory});

  @override
  State<AdminAddAdvisoryScreen> createState() =>
      _AdminAddAdvisoryScreenState();
}

class _AdminAddAdvisoryScreenState
    extends State<AdminAddAdvisoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final cropCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  bool isCritical = false;
  bool loading = false;

  File? pickedImage;
  String? imageUrl;

  @override
  void initState() {
    super.initState();

    // ✏️ EDIT MODE
    if (widget.advisory != null) {
      titleCtrl.text = widget.advisory!.title;
      cropCtrl.text = widget.advisory!.crop;
      descCtrl.text = widget.advisory!.description;
      isCritical = widget.advisory!.isCritical;
      imageUrl = widget.advisory!.image;
    }
  }

  // 📸 PICK IMAGE
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (file != null) {
      setState(() {
        pickedImage = File(file.path);
      });
    }
  }

  // ☁️ UPLOAD TO CLOUDINARY
  Future<String?> uploadImage() async {
    if (pickedImage == null) {
      return imageUrl; // keep old image in edit mode
    }
    return await CloudinaryService.uploadImage(pickedImage!);
  }

  // 🚀 SUBMIT ADVISORY
  Future<void> submitAdvisory() async {
    if (!_formKey.currentState!.validate()) return;

    if (pickedImage == null && imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final imgUrl = await uploadImage();

      final data = {
        'title': titleCtrl.text.trim(),
        'crop': cropCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'image': imgUrl,
        'isCritical': isCritical,
        'date': DateTime.now().toString().substring(0, 10),
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (widget.advisory == null) {
        // ➕ ADD
        await FirebaseFirestore.instance
            .collection('advisories')
            .add(data);
      } else {
        // ✏️ EDIT
        await FirebaseFirestore.instance
            .collection('advisories')
            .doc(widget.advisory!.id)
            .update(data);
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.advisory == null
              ? 'Add Advisory'
              : 'Edit Advisory',
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: kBlueGradient),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              /// 🖼 IMAGE PICKER
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.grey.shade300,
                    image: pickedImage != null
                        ? DecorationImage(
                      image: FileImage(pickedImage!),
                      fit: BoxFit.cover,
                    )
                        : imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: pickedImage == null && imageUrl == null
                      ? const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Colors.black54,
                    ),
                  )
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              _field(titleCtrl, 'Advisory Title'),
              const SizedBox(height: 14),

              _field(cropCtrl, 'Crop Name'),
              const SizedBox(height: 14),

              _field(descCtrl, 'Description', maxLines: 4),
              const SizedBox(height: 14),

              SwitchListTile(
                value: isCritical,
                title: const Text('Critical Alert'),
                activeColor: Colors.red,
                onChanged: (v) => setState(() => isCritical = v),
              ),

              const SizedBox(height: 24),

              /// 🚀 SUBMIT BUTTON
              InkWell(
                onTap: loading ? null : submitAdvisory,
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: kBlueGradient,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      widget.advisory == null
                          ? 'Publish Advisory'
                          : 'Update Advisory',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c,
      String label, {
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      validator: (v) =>
      v == null || v.isEmpty ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
