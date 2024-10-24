import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Screen'),
        backgroundColor: Colors.green, // สีของ AppBar
      ),
      body: Container(
        color: Colors.amber[100], // พื้นหลังของหน้าจอ
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Upload Functionality Coming Soon!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // สีของข้อความ
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // สีพื้นหลังของปุ่ม
                  foregroundColor: Colors.white, // สีตัวอักษรบนปุ่ม
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ทำให้ปุ่มมีขอบโค้งมน
                  ),
                  shadowColor: Colors.black, // เงาของปุ่ม
                  elevation: 5, // ระดับความสูงของปุ่ม (เงา)
                ),
                onPressed: () {
                  // ฟังก์ชันสำหรับอัปโหลดไฟล์
                  print('Upload button pressed');
                },
                child: const Text('Upload File'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
