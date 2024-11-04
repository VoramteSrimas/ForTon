import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_application_food_scan/model/food.dart';
import 'package:flutter_application_food_scan/model/history_model.dart';
import 'package:flutter_application_food_scan/provider/food_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class Camera extends ConsumerStatefulWidget {
  const Camera({super.key});
  @override
  ConsumerState<Camera> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<Camera> {
  File? _image;
  FoodItem? food;
  late ImagePicker _picker;
  late ImageLabeler _imageLabeler;
  String result = 'Result will be shown here';
  String? _foodName;
  bool loadImage = false;

  @override
  void initState() {
    super.initState();
    _picker = ImagePicker();
    loadModel();
  }

  Future<void> loadModel() async {
    final modelPath = await getModelPath('assets/ml/food_metadata.tflite');
    final options = LocalLabelerOptions(
      confidenceThreshold: 0.5,
      modelPath: modelPath,
    );
    _imageLabeler = ImageLabeler(options: options);
  }

  Future<void> doImageLabeling() async {
    if (_image == null) return;

    setState(() {
      loadImage = true;
    });

    try {
      InputImage inputImage = InputImage.fromFile(_image!);
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);
      _foodName = '';
      result = '';
      for (ImageLabel label in labels) {
        var text = label.label;
        final double confidence = label.confidence;
        int spaceIndex = text.indexOf(' ');
        if (spaceIndex != -1) {
          text = text.substring(spaceIndex + 1);
        }
        if (confidence < 0.7) {
          continue;
        } else {
          _foodName = text;
          result = '$text: ${(confidence * 100).toStringAsFixed(2)}%';
          await history(_image!, _foodName!, confidence);
          break;
        }
      }

      final foodList = ref.watch(foodlistProvider);
      setState(() {
        food = findFoodByName(_foodName, foodList);
      });

      print('Food found: $food');
    } catch (e) {
      result = 'Error occurred: $e';
    } finally {
      setState(() {
        loadImage = false;
      });
    }
  }

  FoodItem? findFoodByName(String? name, List<FoodItem> foodList) {
    if (name == null || name.isEmpty) return null;

    final trimmedName = name.trim().toLowerCase();

    for (var food in foodList) {
      if (food.name.toLowerCase().replaceAll(' ', '') == trimmedName) {
        return food;
      }
    }

    return null;
  }

  Future<void> history(File image, String foodName, double confidence) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('food_image/image_user/$userId/${basename(image.path)}');

      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      final DateTime now = DateTime.now();
      String formattedDate = '${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute}';

      History historyData = History(
        imageUrl: imageUrl,
        foodName: foodName,
        confidence: double.parse(confidence.toStringAsFixed(2)),
        userId: userId,
        timestamp: formattedDate,
      );

      final dbRef = FirebaseDatabase.instance.ref('history/$userId');
      await dbRef.push().set(historyData.toMap());

      print('History saved successfully');
    } catch (e) {
      print('Error occurred while saving history: $e');
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  Future<void> imageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future<void> imageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  @override
  void dispose() {
    _imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.shade200,
        centerTitle: true,
        title: const Text("Image Label Example"),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.lightBlue.shade200,
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: 350,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(width: 1, color: Colors.grey),
                  ),
                  child: _image != null
                      ? Image.file(
                          File(_image!.path),
                          fit: BoxFit.contain,
                        )
                      : Center(
                          child: Text(
                            'No image selected',
                            style: fontEnglish.copyWith(fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Mybutton(
                            imageFrom: imageFromGallery, camera: false)),
                    Expanded(
                        child:
                            Mybutton(imageFrom: imageFromCamera, camera: true)),
                  ],
                ),
                if (food != null)
                  SizedBox(
                    height: 150,
                    child: MyListView(foodList: [food!]),
                  ),
                ElevatedButton(
                  onPressed: _image == null ? null : doImageLabeling,
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.grey[400],
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                  ),
                  child: Text(
                    'Submit',
                    style: fontEnglish.copyWith(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: loadImage
                      ? const CircularProgressIndicator()
                      : Text(
                          result.isEmpty ? 'Unknown Food' : result,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
