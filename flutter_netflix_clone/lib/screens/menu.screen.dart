import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_netflix_clone/providers/auth.provider.dart';
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isLoading = authProvider.isLoading;

    ImageProvider? getAvatarImage() {
      if (user?.avatar != null && user!.avatar!.isNotEmpty) {
        try {
          String avatar = user.avatar!;
          if (avatar.startsWith('http')) {
            return NetworkImage(avatar);
          } else if (avatar.startsWith('data:image')) {
            return MemoryImage(base64Decode(avatar.split(',').last));
          } else {
            final base64String = 'data:image/jpeg;base64,$avatar';
            return MemoryImage(base64Decode(base64String.split(',').last));
          }
        } catch (e) {
          return const AssetImage('assets/images/avatar-user.png');
        }
      }
      return const AssetImage('assets/images/avatar-user.png');
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Account', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Color.fromARGB(255, 160, 11, 0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: Row(
                  children: [
                    isLoading
                        ? const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          )
                        : CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: getAvatarImage(),
                            ),
                          ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.username ?? 'Guest',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.white),
                title: const Text('Profile', style: TextStyle(color: Colors.white)),
                onTap: () => context.push('/profile'),
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.white),
                title: const Text('Settings', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.white),
                title: const Text('Help', style: TextStyle(color: Colors.white)),
                onTap: () {},
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text('Logout', style: TextStyle(color: Colors.white)),
                onTap: () async {
                  try {
                    await authProvider.logout();
                    context.go('/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}