import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:b_connect_task/core/constants/app_colors.dart';
import 'package:b_connect_task/core/components/custom_search_bar.dart';
import 'package:b_connect_task/core/components/custom_user_item.dart';
import 'package:b_connect_task/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:b_connect_task/features/chat/presentation/cubit/chat_state.dart';
import 'package:b_connect_task/features/chat/presentation/chat_detail_page.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ChatCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchUsers(String query) {
    context.read<ChatCubit>().loadUsers(searchQuery: query);
  }

  void _navigateToDetail(BuildContext context, String userId, String name) {
    context.read<ChatCubit>().selectUser(userId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(userName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.main,
                AppColors.main.withOpacity(0.9),
                AppColors.main.withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'المحادثات',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          CustomSearchBar(
            controller: _searchController,
            onSearch: _searchUsers,
            hintText: 'البحث عن طريق البريد الإلكتروني',
          ),
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.status == ChatStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                if (state.status == ChatStatus.error) {
                  return Center(
                    child: Text(
                      state.errorMessage ?? 'حدث خطأ',
                      style: const TextStyle(
                        color: Colors.red,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  );
                }
                
                if (state.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'لا يوجد مستخدمين',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, index) {
                    final user = state.users[index];
                    return CustomUserItem(
                      name: user['name'],
                      email: user['email'],
                      onTap: () => _navigateToDetail(
                        context,
                        user['id'],
                        user['name'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _searchController.clear();
          context.read<ChatCubit>().loadUsers();
        },
        backgroundColor: AppColors.main,
        child: const Icon(Icons.message),
      ),
    );
  }
}