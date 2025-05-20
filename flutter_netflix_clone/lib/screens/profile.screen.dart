import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_netflix_clone/providers/auth.provider.dart';
import 'package:flutter_netflix_clone/utils/helpers.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _avatarUrlController;
  bool _isLoading = false;
  String? _usernameError;
  String? _dobError;
  String? _avatarError;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _dobController = TextEditingController(
      text: user?.birthDate != null ? formatDate(user!.birthDate) : '',
    );
    _avatarUrlController = TextEditingController(text: user?.avatar ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime

(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = formatDate(picked.toIso8601String());
        _dobError = null;
      });
    }
  }

  bool _validateInputs() {
    setState(() {
      _usernameError = null;
      _dobError = null;
      _avatarError = null;
    });

    bool isValid = true;
    if (_usernameController.text.isEmpty || _usernameController.text.length < 3) {
      setState(() {
        _usernameError = 'Username must be at least 3 characters';
      });
      isValid = false;
    }

    if (_dobController.text.isNotEmpty) {
      try {
        final dob = DateTime.parse(_dobController.text.split('/').reversed.join('-'));
        if (dob.isAfter(DateTime.now())) {
          setState(() {
            _dobError = 'Date of birth cannot be in the future';
          });
          isValid = false;
        }
      } catch (e) {
        setState(() {
          _dobError = 'Invalid date format (use DD/MM/YYYY)';
        });
        isValid = false;
      }
    }
    

    return isValid;
  }

  Future<void> _saveChanges() async {
    if (!_validateInputs()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateUser(
        username: _usernameController.text,
        avatar: _avatarUrlController.text.isNotEmpty ? _avatarUrlController.text : null,
        birthDate: _dobController.text.isNotEmpty ? parseDateToIso(_dobController.text) : null,
      );
      showSnackBar(context, 'Profile updated successfully');
      context.go('/menu');
    } catch (e) {
      showSnackBar(context, 'Failed to update profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ImageProvider? getAvatarImage() {
    final avatarUrl = _avatarUrlController.text;
    if (avatarUrl.isNotEmpty) {
      try {
        if (avatarUrl.startsWith('http')) {
          return NetworkImage(avatarUrl);
        } else if (avatarUrl.startsWith('data:image')) {
          return MemoryImage(base64Decode(avatarUrl.split(',').last));
        } else {
          // Base64 thô từ database
          final base64String = 'data:image/jpeg;base64,$avatarUrl';
          return MemoryImage(base64Decode(base64String.split(',').last));
        }
      } catch (e) {
        return const AssetImage('assets/images/avatar-user.png');
      }
    }
    return const AssetImage('assets/images/avatar-user.png');
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // ignore: unused_local_variable
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundImage: getAvatarImage(),
                    ),
                  ),
                  if (_isLoading)
                    const Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Avatar URL',
              controller: _avatarUrlController,
              icon: Icons.image,
              errorText: _avatarError,
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Username',
                    controller: _usernameController,
                    icon: Icons.person_outline,
                    errorText: _usernameError,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _isLoading ? null : _selectDate,
                    child: _buildTextField(
                      label: 'Date of Birth',
                      controller: _dobController,
                      icon: Icons.calendar_today,
                      enabled: false,
                      errorText: _dobError,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _saveChanges,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    IconData? icon,
    TextEditingController? controller,
    String? errorText,
    bool enabled = true,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    return TextField(
      obscureText: obscureText,
      controller: controller,
      style: const TextStyle(color: Colors.white),
      enabled: enabled,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
        suffixIcon: suffixIcon,
        errorText: errorText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }
}