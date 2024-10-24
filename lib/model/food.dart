import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final int calories;
  final String imageUrl;

  FoodItem({
    this.id = '',
    required this.name,
    required this.calories,
    required this.imageUrl,
  });

  // Convert a FoodItem object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'calories': calories,
    };
  }

  // Create a FoodItem object from a Map object
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'],
      calories: map['calories'],
      imageUrl: '',
    );
  }

  // Convert a FoodItem object into a Firestore DocumentSnapshot
  factory FoodItem.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FoodItem(
      id: doc.id,
      name: data['name'],
      calories: data['calories'],
      imageUrl: '',
    );
  }
}
