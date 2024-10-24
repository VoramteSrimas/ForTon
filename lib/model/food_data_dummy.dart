import 'package:flutter_application_food_scan/model/food.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ตัวอย่างข้อมูลชื่ออาหารและแคลอรี่
List<FoodItem> dummyFoodData = [
  FoodItem(
    name: 'ข้าวมันไก่',
    calories: 585,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%82%E0%B9%89%E0%B8%B2%E0%B8%A7%E0%B8%A1%E0%B8%B1%E0%B8%99%E0%B9%84%E0%B8%81%E0%B9%88%2F860_jpg.rf.89938ece10e9ac9c62049f438416242f.jpg?alt=media&token=b2f294dd-8905-4270-a8a1-76c8e27c4124',
  ),
  FoodItem(
    name: 'ข้าวผัดหมู',
    calories: 561,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%82%E0%B9%89%E0%B8%B2%E0%B8%A7%E0%B8%9C%E0%B8%B1%E0%B8%94%E0%B8%AB%E0%B8%A1%E0%B8%B9%2F9e7a1f12969844c0a1f537c5d95662ac.webp?alt=media&token=e9b28f1d-4572-4754-a253-955f619975c3',
  ),
  FoodItem(
    name: 'แกงเขียวหวาน',
    calories: 240,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B9%81%E0%B8%81%E0%B8%87%E0%B9%80%E0%B8%82%E0%B8%B5%E0%B8%A2%E0%B8%A7%E0%B8%AB%E0%B8%A7%E0%B8%B2%E0%B8%99%2F353_jpg.rf.948a11f74e3d0c1cc9240da83cdff4f0.jpg?alt=media&token=668ad096-ac97-480a-bdfc-00a9b65ae6bd',
  ),
  FoodItem(
    name: 'ข้าวไข่เจียว',
    calories: 445,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B9%84%E0%B8%82%E0%B9%88%E0%B9%80%E0%B8%88%E0%B8%B5%E0%B8%A2%E0%B8%A7%2F957_jpg.rf.129db30c8fd40336332d13abffa113fa.jpg?alt=media&token=76e63c41-08da-4c4e-85ff-ec7d239e9461',
  ),
  FoodItem(
    name: 'ราดหน้าหมู',
    calories: 644,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%A3%E0%B8%B2%E0%B8%94%E0%B8%AB%E0%B8%99%E0%B9%89%E0%B8%B2%2Fb2we-listing.jpg?alt=media&token=d4c3e8bf-95b9-4989-8932-4a9134d81b75',
  ),
  FoodItem(
    name: 'ข้าวขาหมู',
    calories: 690,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%82%E0%B9%89%E0%B8%B2%E0%B8%A7%E0%B8%82%E0%B8%B2%E0%B8%AB%E0%B8%A1%E0%B8%B9%2F752_jpg.rf.0050c7f378803ef0038ba966a8583bc8.jpg?alt=media&token=0e0df199-fdef-4687-96e6-45e742f01008',
  ),
  FoodItem(
    name: 'โจ๊ก',
    calories: 160,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B9%82%E0%B8%88%E0%B9%8A%E0%B8%81%2F1153_jpg.rf.46e099169854b54c811a60bb24551b4e.jpg?alt=media&token=ed7ea898-6a66-4f4a-b148-f3655ff2a4d0',
  ),
  FoodItem(
    name: 'ต้มยำกุ้ง',
    calories: 873,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%95%E0%B9%89%E0%B8%A1%E0%B8%A2%E0%B8%B3%2F1350.jpg?alt=media&token=ae38d170-c4d9-476e-9129-b724c3fc1979',
  ),
  FoodItem(
    name: 'ข้าวกะเพรา',
    calories: 580,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B8%81%E0%B8%B0%E0%B9%80%E0%B8%9E%E0%B8%A3%E0%B8%B2%2F3.jpg?alt=media&token=a436cc21-3dd1-4a1b-82a2-023c5ffae33a',
  ),
  FoodItem(
    name: 'แกงจืด',
    calories: 110,
    imageUrl:
        'https://firebasestorage.googleapis.com/v0/b/food-scan704.appspot.com/o/food%2F%E0%B9%81%E0%B8%81%E0%B8%87%E0%B8%88%E0%B8%B7%E0%B8%94%2F1285312277.jpg?alt=media&token=3c417f17-6e4a-428b-a1cb-5dc40fa257e1',
  ),
];

// add dummy data to Firestore
Future<void> addFood(FoodItem food) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('foods').add(food.toMap());
}

Future<void> addDummyFoods() async {
  for (var food in dummyFoodData) {
    await addFood(food);
  }
}
