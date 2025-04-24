import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NetworkHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isConnected() async {
    try {
      await _firestore.collection('connectivity_check').doc('status').get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user's online status
  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle error
      print('Error updating user status: $e');
    }
  }

  StreamSubscription<User?> listenToAuthChanges(Function(User?) onUserChanged) {
    return _auth.authStateChanges().listen((User? user) {
      onUserChanged(user);
      
      if (user != null) {
        // User is signed in, update status to online
        updateUserStatus(user.uid, true);
      }
    });
  }

  Future<void> setUserOfflineOnDisconnect(String userId) async {
    try {      await _firestore.collection('users').doc(userId).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Handle error
      print('Error setting offline status: $e');
    }
  }

  Future<T> retryOperation<T>(Future<T> Function() operation, {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        
        await Future.delayed(Duration(milliseconds: 300 * (attempts * attempts)));
      }
    }
    throw Exception('Operation failed after $maxRetries attempts');
  }
}