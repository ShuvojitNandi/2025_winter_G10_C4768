import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/product_review.dart';


class ReviewController {
  final CollectionReference _reviewCollection =
      FirebaseFirestore.instance.collection('reviews');

  Future<void> addReview(Review review) async {
    await _reviewCollection.add(review.toMap());
  }

  Future<void> updateReview(Review review) async {
    if (review.reviewId == null) return;
    await _reviewCollection.doc(review.reviewId).update(review.toMap());
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewCollection.doc(reviewId).delete();
  }

  Future<List<Review>> getAllReviews() async {
    final query = await _reviewCollection.get();
    return query.docs.map((doc) => Review.fromMap(doc)).toList();
  }

  Future<Review?> getReviewById(String reviewId) async {
    final doc = await _reviewCollection.doc(reviewId).get();
    if (doc.exists) return Review.fromMap(doc);
    return null;
  }

  Future<List<Review>> getReviewsByProductId(String vendorProductId) async {
    final query = await _reviewCollection
        .where('vendorProductId', isEqualTo: vendorProductId)
        .get();
    return query.docs.map((doc) => Review.fromMap(doc)).toList();
  }

  Future<List<Review>> getReviewsByVendorId(String vendorId) async {
    final query = await _reviewCollection
        .where('vendorId', isEqualTo: vendorId)
        .get();
    return query.docs.map((doc) => Review.fromMap(doc)).toList();
  }

  Future<String> uploadReviewImage(File imageFile, String reviewId) async {
    try {
      final storageRef =
          FirebaseStorage.instance.ref().child('review_images/$reviewId.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception("Failed to upload review image: $e");
    }
  }
}
