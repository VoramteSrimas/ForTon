class History {
  final String imageUrl;
  final String foodName;
  final String timestamp;
  final int calories;

  History( {
    required this.imageUrl,
    required this.foodName,
    required this.timestamp,
    required this.calories,
  });

  // Convert a Map to a History object
  factory History.fromMap(Map<dynamic, dynamic> map) {
    return History(
      imageUrl: map['imageUrl'] ?? '',
      foodName: map['foodName'] ?? '',
      timestamp: map['timestamp'] ?? '',
      calories: map['calories'] ?? 0,
    );
  }

  // Convert a History object to a Map
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'foodName': foodName,
      'timestamp': timestamp,
      'calories': calories,
    };
  }
}
