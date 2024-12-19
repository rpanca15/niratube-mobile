import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late UserService userService;
  late AuthService authService;
  bool isEditing = false;
  bool isLoading = true; // Menambahkan indikator loading
  Map<String, dynamic> userData = {};
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userService = UserService();
    authService = AuthService();
    _loadUserData();
  }

  // Memuat data pengguna dari API
  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true; // Menandakan bahwa data sedang dimuat
    });

    try {
      // Mengambil token dari SharedPreferences melalui AuthService
      final token = await authService.getToken();
      if (token != null) {
        // Mendapatkan profil pengguna berdasarkan token
        var response = await userService.getUserProfile();
        if (response != null) {
          setState(() {
            userData = response;
            _nameController.text = userData['name'];
            _emailController.text = userData['email'];
            isLoading = false; // Data telah dimuat
          });
        } else {
          _showError("User data not found.");
        }
      } else {
        _showError("User not logged in.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError("Error loading user data: $e");
    }
  }

  // Menyimpan perubahan data pengguna
  Future<void> _saveProfile() async {
    try {
      Map<String, dynamic> updatedData = {
        'name': _nameController.text,
        'email': _emailController.text,
      };
      var response =
          await userService.updateUser(userData['id'].toString(), updatedData);
      setState(() {
        userData = response;
        isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      _showError("Error updating profile: $e");
    }
  }

  // Membatalkan perubahan dan kembali ke tampilan profil
  void _cancelEdit() {
    setState(() {
      _nameController.text = userData['name'];
      _emailController.text = userData['email'];
      isEditing = false;
    });
  }

  // Menampilkan notifikasi error
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child:
                    CircularProgressIndicator()) // Menampilkan indikator loading saat memuat data
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isEditing)
                    // Tampilan saat sedang mengedit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(labelText: 'Name'),
                        ),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _cancelEdit,
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _saveProfile,
                              child: Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    // Tampilan profil saat tidak sedang mengedit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${userData['name']}',
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Email: ${userData['email']}',
                            style: TextStyle(fontSize: 18)),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: Text('Refresh Profile'),
                        ),
                      ],
                    ),
                ],
              ),
      ),
    );
  }
}
