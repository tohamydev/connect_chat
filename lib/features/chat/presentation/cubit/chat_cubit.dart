import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  StreamSubscription? _messagesSubscription;

  ChatCubit({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        super(const ChatState());

  Future<void> loadUsers({String? searchQuery}) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        emit(state.copyWith(
          status: ChatStatus.error,
          errorMessage: 'لم يتم تسجيل الدخول',
        ));
        return;
      }

      QuerySnapshot usersSnapshot;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Search for users by email
        usersSnapshot = await _firestore
            .collection('users')
            .where('email', isGreaterThanOrEqualTo: searchQuery)
            .where('email', isLessThanOrEqualTo: searchQuery + '\uf8ff')
            .get();
      } else {
        // Get all users except current user
        usersSnapshot = await _firestore.collection('users').get();
      }

      final users = usersSnapshot.docs
          .where((doc) => doc.id != currentUser.uid)
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'مستخدم',
          'email': data['email'] ?? '',
        };
      })
          .toList();

      emit(state.copyWith(
        status: ChatStatus.loaded,
        users: users,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'حدث خطأ أثناء تحميل المستخدمين',
      ));
    }
  }

  void selectUser(String userId) {
    emit(state.copyWith(
      selectedUserId: userId,
    ));
    _listenToMessages(userId);
  }

  void _listenToMessages(String userId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final chatId = _getChatId(currentUser.uid, userId);

    _messagesSubscription?.cancel();
    _messagesSubscription = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      emit(state.copyWith(
        messages: snapshot.docs,
      ));
    });
  }

  Future<void> sendMessage(String text) async {
    final currentUser = _auth.currentUser;
    final selectedUserId = state.selectedUserId;

    if (currentUser == null || selectedUserId == null) return;

    final chatId = _getChatId(currentUser.uid, selectedUserId);

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'sender': currentUser.uid,
      'text': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendLocation() async {
    final currentUser = _auth.currentUser;
    final selectedUserId = state.selectedUserId;

    if (currentUser == null || selectedUserId == null) return;

    try {
      final location = Location();
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return;
        }
      }

      PermissionStatus permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          return;
        }
      }

      final currentLocation = await location.getLocation();
      final chatId = _getChatId(currentUser.uid, selectedUserId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'sender': currentUser.uid,
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'type': 'location',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'حدث خطأ أثناء إرسال الموقع',
      ));
    }
  }

  Future<void> sendSelectedLocation(LatLng position) async {
    final currentUser = _auth.currentUser;
    final selectedUserId = state.selectedUserId;

    if (currentUser == null || selectedUserId == null) return;

    try {
      final chatId = _getChatId(currentUser.uid, selectedUserId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'sender': currentUser.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'type': 'location',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'حدث خطأ أثناء إرسال الموقع',
      ));
    }
  }

  Future<void> sendSelectedLocationWithAddress(LatLng position, String address) async {
    final currentUser = _auth.currentUser;
    final selectedUserId = state.selectedUserId;

    if (currentUser == null || selectedUserId == null) return;

    try {
      final chatId = _getChatId(currentUser.uid, selectedUserId);

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'sender': currentUser.uid,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': address,
        'type': 'location',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      emit(state.copyWith(
        status: ChatStatus.error,
        errorMessage: 'حدث خطأ أثناء إرسال الموقع',
      ));
    }
  }

  String _getChatId(String uid1, String uid2) {
    List<String> ids = [uid1, uid2];
    ids.sort(); // Ensure consistent chat ID regardless of order
    return ids.join('_');
  }

  void clearSelectedUser() {

    _messagesSubscription?.cancel();
    emit(state.copyWith(
      selectedUserId: null,
      messages: null,
    ));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}