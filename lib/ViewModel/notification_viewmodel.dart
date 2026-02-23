import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rika_store/Model/notification_model.dart';

class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  void listenToNotifications(String userId) {
    if (userId.isEmpty) return;

    _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _notifications = snapshot.docs
                .map(
                  (doc) => NotificationModel.fromFirestore(doc.data(), doc.id),
                )
                .toList();
            notifyListeners();
          },
          onError: (error) {
            debugPrint("❌ Error listening to notifications: $error");
          },
        );
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint("❌ Error marking as read: $e");
    }
  }
}
