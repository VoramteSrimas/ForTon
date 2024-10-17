import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FoodImagePicker extends StatefulWidget {
  const FoodImagePicker({super.key});

  @override
  State<FoodImagePicker> createState() {
    return _FoodImagePicker();
  }
}

class _FoodImagePicker extends State<FoodImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50, 
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }

    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey,
        foregroundImage: _pickedImageFile !=null ? FileImage(_pickedImageFile!) : null,
      ),
      TextButton.icon(
        onPressed: _pickImage,
        icon: const Icon(Icons.image),
        label: Text(
          'Add Image',
         style: TextStyle(
          color: Theme.of(context).primaryColor,
        ),),
      )
    ],
  );
  }
}