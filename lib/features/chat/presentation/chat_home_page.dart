import 'package:flutter/material.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Home'),
      ),
      body: const Center(
        child: Text('Welcome to Chat App'),
      ),
    );
  }
}