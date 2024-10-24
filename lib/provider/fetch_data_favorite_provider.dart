import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_food_scan/model/food.dart';

class FoodNotifier extends StateNotifier<List<FoodItem>> {
  FoodNotifier() : super([]);

  // This method will start listening to changes in Firestore
  void fetchFavoriteFood(String userId) {
    // Stream to listen to user document changes
    final userDocStream = FirebaseFirestore.instance.collection('users').doc(userId).snapshots();

    userDocStream.listen((userDoc) async {
      if (!userDoc.exists) {
        print('User not found');
        state = [];
        return;
      }

      final data = userDoc.data();
      final favoriteFoodIds = List<String>.from(data?['favoriteFood'] ?? []);

      final List<FoodItem> foodList = [];

      for (var foodId in favoriteFoodIds) {
        final foodSnapshot = await FirebaseFirestore.instance.collection('foods').doc(foodId).get();
        if (foodSnapshot.exists) {
          foodList.add(FoodItem.fromMap(foodSnapshot.data()!));
        }
      }

      state = foodList;
    }, onError: (error) {
      print('Error listening to user document: $error');
      state = [];
    });
  }
}

final foodProvider = StateNotifierProvider<FoodNotifier, List<FoodItem>>((ref) {
  return FoodNotifier();
});
