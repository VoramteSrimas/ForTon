import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // ฟังก์ชันสำหรับเลือกรูปภาพจากแกลเลอรี
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันสำหรับถ่ายรูปจากกล้อง
  Future<void> _captureImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชันสำหรับอัปโหลดรูปภาพไปยัง Firebase Storage
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      print('No image selected');
      return;
    }

    try {
      // สร้างชื่อไฟล์ใหม่จากเวลาปัจจุบัน
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // อ้างอิงไปยังตำแหน่งที่จัดเก็บใน Firebase Storage
      Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');

      // อัปโหลดไฟล์ไปยัง Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;

      // ดึง URL ของรูปภาพที่อัปโหลด
      String imageUrl = await snapshot.ref.getDownloadURL();

      // บันทึกข้อมูล URL ลงใน Firestore
      await FirebaseFirestore.instance.collection('images').add({
        'url': imageUrl,
        'uploaded_at': Timestamp.now(),
      });

      print('Upload successful: $imageUrl');
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(
                    _selectedImage!,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                  )
                : const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImageFromGallery,
              child: const Text('Select Image from Gallery'),
            ),
            ElevatedButton(
              onPressed: _captureImageFromCamera,
              child: const Text('Capture Image from Camera'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: const Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
