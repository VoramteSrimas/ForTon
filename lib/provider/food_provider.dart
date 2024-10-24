import 'package:flutter_application_food_scan/model/food.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodNotifier extends StateNotifier<List<FoodItem>> {
  FoodNotifier() : super([]);

  Future<void> fetchFish() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('foods').get();
      state = snapshot.docs.map((doc) => FoodItem.fromDocumentSnapshot(doc)).toList();
    } catch (error) {
      // Handle error
      state = [];
    }
  }
}

final foodlistProvider = StateNotifierProvider<FoodNotifier, List<FoodItem>>((ref) => FoodNotifier());