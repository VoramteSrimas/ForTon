import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // ต้องใช้การตั้งค่าจาก flutterfire configure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TensorFlow Lite Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageClassificationScreen(),
    );
  }
}

class ImageClassificationScreen extends StatefulWidget {
  const ImageClassificationScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageClassificationScreenState createState() => _ImageClassificationScreenState();
}

class _ImageClassificationScreenState extends State<ImageClassificationScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  String _result = "Result will be displayed here";

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  // ฟังก์ชันสำหรับโหลดโมเดล TensorFlow Lite
  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/model/model_unquant.tflite",
    );
  print("Model loaded: $res");
  }

  // ฟังก์ชันสำหรับประมวลผลภาพ
  Future<void> classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 5,
      threshold: 0.5,
    );
    setState(() {
      _result = output != null ? output.toString() : "No results";
    });
  }

  // ฟังก์ชันสำหรับเลือกรูปภาพจากแกลเลอรี
  Future<void> pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      classifyImage(_selectedImage!);
    }
  }

  // ฟังก์ชันสำหรับถ่ายภาพจากกล้อง
  Future<void> captureImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      classifyImage(_selectedImage!);
    }
  }

  // ฟังก์ชันสำหรับอัปโหลดรูปภาพไปยัง Firebase
  Future<void> uploadImageToFirebase() async {
    if (_selectedImage == null) {
      print("No image selected");
      return;
    }

    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageRef = FirebaseStorage.instance.ref().child('images/$fileName');
      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('images').add({
        'url': imageUrl,
        'uploaded_at': Timestamp.now(),
      });

      print("Upload successful: $imageUrl");
    } catch (e) {
      print("Upload failed: $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classification with TFLite'),
      ),
      body: Center(
        child: SingleChildScrollView(
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
                onPressed: pickImageFromGallery,
                child: const Text('Select Image from Gallery'),
              ),
              ElevatedButton(
                onPressed: captureImageFromCamera,
                child: const Text('Capture Image from Camera'),
              ),
              ElevatedButton(
                onPressed: uploadImageToFirebase,
                child: const Text('Upload Image to Firebase'),
              ),
              const SizedBox(height: 20),
              Text(
                _result,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}