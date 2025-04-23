import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatStatus { initial, loading, loaded, error }

class ChatState extends Equatable {
  final ChatStatus status;
  final List<Map<String, dynamic>> users;
  final List<QueryDocumentSnapshot>? messages;
  final String? selectedUserId;
  final String? errorMessage;

  const ChatState({
    this.status = ChatStatus.initial,
    this.users = const [],
    this.messages,
    this.selectedUserId,
    this.errorMessage,
  });

  ChatState copyWith({
    ChatStatus? status,
    List<Map<String, dynamic>>? users,
    List<QueryDocumentSnapshot>? messages,
    String? selectedUserId,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      users: users ?? this.users,
      messages: messages ?? this.messages,
      selectedUserId: selectedUserId ?? this.selectedUserId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        messages,
        selectedUserId,
        errorMessage,
      ];
}