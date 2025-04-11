import 'package:cloud_firestore/cloud_firestore.dart';


class Review {
  final String? reviewId;
  final String vendorProductId;
  final String vendorId;
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final String? imageUrl;
  final Timestamp timestamp;

  Review({
    this.reviewId,
    required this.vendorProductId,
    required this.vendorId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    this.imageUrl,
    required this.timestamp,
  });


  Map<String, dynamic> toMap() {
    return {
      'vendorProductId': vendorProductId,
      'vendorId': vendorId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'rating': rating,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }


  factory Review.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      reviewId: doc.id,
      vendorProductId: data['vendorProductId'],
      vendorId: data['vendorId'],
      userId: data['userId'],
      userName: data['userName'],
      comment: data['comment'],
      rating: (data['rating'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      timestamp: data['timestamp'],
    );
  }
}
