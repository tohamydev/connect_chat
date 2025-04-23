import 'dart:io';
import 'dart:ui';

import 'package:b_connect_task/core/components/app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:b_connect_task/core/constants/app_colors.dart';
import 'package:b_connect_task/core/components/custom_message_bubble.dart';
import 'package:b_connect_task/core/components/location_message_bubble.dart';
import 'package:b_connect_task/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:b_connect_task/features/chat/presentation/cubit/chat_state.dart';
import 'package:b_connect_task/features/chat/presentation/location_view_screen.dart';
import 'package:place_picker_google/place_picker_google.dart';

class ChatDetailPage extends StatefulWidget {
  final String userName;

  const ChatDetailPage({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
  bool _isComposing = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatCubit>().sendMessage(_messageController.text.trim());
    setState(() {
      _messageController.clear();
      _isComposing = false;
    });
  }

  Future<void> _openLocationPicker() async {
    final result = await  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return PlacePicker(
            apiKey: Platform.isAndroid
                ? "AIzaSyDGzG6SU9IVPzw2T6YTAH6YAgnAfzM1lsU"
                : "AIzaSyDGzG6SU9IVPzw2T6YTAH6YAgnAfzM1lsU",
            onPlacePicked: (LocationResult result) {
              setState(() {
                final LatLng position = LatLng(
                  result.latLng!.latitude,
                  result.latLng!.longitude,
                );
                final String address = result.formattedAddress ?? '';
                context.read<ChatCubit>().sendSelectedLocationWithAddress(position, address);
              });
              Navigator.of(context).pop();
            },
            initialLocation: const LatLng(
              29.378586,
              47.990341,
            ),
            usePinPointingSearch: true,
            searchInputConfig: const SearchInputConfig(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              autofocus: false,
              textDirection: TextDirection.ltr,
            ),
            searchInputDecorationConfig:
            const SearchInputDecorationConfig(
              hintText: "ابحث عن مكان .....",
            ),
          );
        },
      ),
    );
    ;

    if (result != null && result is Map<String, dynamic>) {
      final LatLng? position = result['position'] as LatLng?;
      final String address = result['address'] as String? ?? '';
      
      if (position != null) {
        context.read<ChatCubit>().sendSelectedLocationWithAddress(position, address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize:  Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: Colors.white.withOpacity(0.2),
              elevation: 0,
              leading: IconButton(
                icon:  Icon(
                  CupertinoIcons.back,
                  color: AppColors.main,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.main,
                    child: Text(
                      widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.userName,
                    style:  TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 18,
                      color: AppColors.main,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
          
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.main.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state.messages == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.messages!.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد رسائل بعد. أرسل أول رسالة!',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.only(top: 15, bottom: 10),
                      itemCount: state.messages!.length,
                      itemBuilder: (context, index) {
                        final message = state.messages![index];
                        final data = message.data() as Map<String, dynamic>;
                        final isMe = data['sender'] == currentUserId;
                        final messageType = data['type'] ?? 'text';
                        final timestamp = data['timestamp'] as Timestamp?;
                        final dateTime = timestamp?.toDate();
                        
                        if (messageType == 'location') {
                          return LocationMessageBubble(
                            isMe: isMe,
                            latitude: data['latitude'],
                            longitude: data['longitude'],
                            address: data['address'] ?? 'موقع غير معروف',
                            time: dateTime,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationViewScreen(
                                    latitude: data['latitude'],
                                    longitude: data['longitude'],
                                    address: data['address'] ?? 'موقع غير معروف',
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        
                        return CustomMessageBubble(
                          text: data['text'] ?? '',
                          isMe: isMe,
                          time: dateTime,
                        );
                      },
                    );
                  },
                ),
              ),
              _buildIOSStyleMessageComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIOSStyleMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // زر خريطة جوجل
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(
                CupertinoIcons.location,
                color: AppColors.main,
                size: 26,
              ),
              onPressed: _openLocationPicker,
              splashRadius: 20,
              tooltip: 'إرسال موقع من الخريطة',
            ),
          ),
          // حقل إدخال الرسائل
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: TextField(
                        controller: _messageController,
                        textDirection: TextDirection.rtl,
                        decoration: const InputDecoration(
                          hintText: 'رسالة...',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            color: Colors.grey,
                          ),
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                        ),
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        onChanged: (text) {
                          setState(() {
                            _isComposing = text.trim().isNotEmpty;
                          });
                        },
                      ),
                    ),
                  ),
                  // زر الإرسال
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 4, bottom: 4),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isComposing ? _sendMessage : null,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            CupertinoIcons.arrow_up_circle_fill,
                            color: _isComposing ? AppColors.main : Colors.grey,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}