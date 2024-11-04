import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Colors.green, // สีของ AppBar
      ),
      body: Container(
        color: Colors.amber[100], // สีพื้นหลังของหน้า
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // รูปภาพข้างบนสุด
              Container(
                margin: const EdgeInsets.only(bottom: 20), // เว้นระยะด้านล่าง
                child: Image.asset(
                  'assets/images/calories.png', // path ของรูปภาพ
                  width: 200, // กำหนดขนาดความกว้าง
                  height: 200, // กำหนดขนาดความสูง
                  fit: BoxFit.cover, // จัดการขนาดของรูปภาพให้พอดี
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo, // สีพื้นหลังของปุ่ม
                  foregroundColor: Colors.white, // สีตัวอักษรของปุ่ม
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20), // ขนาดของปุ่ม
                  textStyle: const TextStyle(fontSize: 18), // ขนาดตัวอักษร
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // ทำให้ปุ่มมีขอบโค้งมน
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/camera');
                },
                child: const Text('Go to Camera Screen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
