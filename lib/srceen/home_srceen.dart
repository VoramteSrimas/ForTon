import 'package:flutter/material.dart';
import 'package:flutter_application_food_scan/srceen/camera.dart';

class HomeSrceen extends StatefulWidget {
  const HomeSrceen({super.key});

  @override
  State<HomeSrceen> createState() {
    return _HomeSreenState();
  }
}

class _HomeSreenState extends State<HomeSrceen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/calories.png'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Action when button is pressed
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('เริ่มต้นการใช้งาน'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
