import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteFoodNotifier extends StateNotifier<List<String>> {
  final String userId;

  FavoriteFoodNotifier(this.userId) : super([]) {
    _loadFavorites();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _loadFavorites() async {
    try {
      // Load favorite food IDs from the user's Firestore document
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data();
        // Use 'favoriteFoodIds' field to store food IDs
        state = List<String>.from(data?['favoriteFoodIds'] ?? []);
      }
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> addFavorite(String foodId) async {
    try {
      // Add foodId to the list of favorite food IDs
      final updatedFavorites = [...state, foodId];
      await _firestore.collection('users').doc(userId).set(
        {'favoriteFoodIds': updatedFavorites},
        SetOptions(merge: true),
      );
      state = updatedFavorites;
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String foodId) async {
    try {
      // Remove the foodId from the list of favorite food IDs
      final updatedFavorites = state.where((id) => id != foodId).toList();
      await _firestore.collection('users').doc(userId).set(
        {'favoriteFoodIds': updatedFavorites},
        SetOptions(merge: true),
      );
      state = updatedFavorites;
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }
}

final favoriteFoodProvider = StateNotifierProvider.family<FavoriteFoodNotifier, List<String>, String>(
  (ref, userId) => FavoriteFoodNotifier(userId),
);
