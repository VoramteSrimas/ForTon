import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

// ตัวอย่างข้อมูลแคลอรี่ของอาหาร
Map<String, int> calorieData = {
  'แกงเขียวหวาน': 240,
  'ข้าวมันไก่': 585,
  'ข้าวำะเพรา': 580,
  'ข้าวไข่เจียว': 445,
  'ข้าวผัดหมู': 561,
  'ราดหน้าหมู': 644,
  'ข้าวขาหมู': 690,
  'โจ๊ก': 160,
  'แกงจืด': 110,
  'ต้มยำกุ้ง': 873,
  // เพิ่มข้อมูลอาหารและแคลอรี่ที่ต้องการได้ที่นี่
};

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _result = "Result will be displayed here";

  late final ImageLabeler _imageLabeler;

  @override
  void initState() {
    super.initState();
    _initializeImageLabeler(); // เรียกใช้ฟังก์ชันการโหลดโมเดลเมื่อเริ่มต้น
  }

  // ฟังก์ชันการโหลดโมเดลจาก assets
  void _initializeImageLabeler() async {
    final modelPath = await _loadCustomModel();
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.5,
      modelPath: modelPath,
    );
    _imageLabeler = ImageLabeler(options: options);
  }

  // ฟังก์ชันการดึง path ของโมเดลจาก assets
  Future<String> _loadCustomModel() async {
    // เราต้องระบุตำแหน่งโมเดลใน assets ที่เราใช้
    return 'assets/model/model.tflite';
  }

  Future<void> classifyImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final labels = await _imageLabeler.processImage(inputImage);

    if (labels.isEmpty) {
      setState(() {
        _result = "No results";
      });
      return;
    }

    setState(() {
      _result = labels.where((label) {
        // ตรวจสอบชื่ออาหารใน calorieData โดยแปลงเป็นตัวพิมพ์เล็ก
        return calorieData.containsKey(label.label.toLowerCase());
      }).map((label) {
        String foodName = label.label.toLowerCase(); // ใช้ตัวพิมพ์เล็กทั้งหมดเพื่อให้ตรงกับรายการ
        int calories = calorieData[foodName] ?? 0; // หากไม่มีข้อมูลแคลอรี่ให้เป็น 0
        return "$foodName: ${(label.confidence * 100).toStringAsFixed(2)}% confidence\nCalories: $calories kcal";
      }).join("\n\n");
    });
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      classifyImage(_selectedImage!);
    }
  }

  Future<void> captureImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      classifyImage(_selectedImage!);
    }
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
        backgroundColor: Colors.green, // สีของ AppBar
      ),
      body: Container(
        color: Colors.amber[100], // สีพื้นหลังของหน้าจอ
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        height: 224,
                        width: 224,
                        fit: BoxFit.cover,
                      )
                    : const Text(
                        'No image selected',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // สีพื้นหลังของปุ่ม
                    foregroundColor: Colors.white, // สีตัวอักษรของปุ่ม
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15), // ขนาดปุ่ม
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // ขอบโค้งมน
                    ),
                    shadowColor: Colors.black,
                    elevation: 5, // เพิ่มเงาปุ่ม
                  ),
                  onPressed: pickImageFromGallery,
                  child: const Text('Select Image from Gallery'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo, // สีพื้นหลังของปุ่ม
                    foregroundColor: Colors.white, // สีตัวอักษรของปุ่ม
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15), // ขนาดปุ่ม
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // ขอบโค้งมน
                    ),
                    shadowColor: Colors.black,
                    elevation: 5, // เพิ่มเงาปุ่ม
                  ),
                  onPressed: captureImageFromCamera,
                  child: const Text('Capture Image from Camera'),
                ),
                const SizedBox(height: 20),
                Text(
                  _result,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
