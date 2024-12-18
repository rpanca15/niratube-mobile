import 'package:flutter/material.dart';
import '../services/video_service.dart'; // Import sesuai dengan path service Anda

class EditVideoPage extends StatefulWidget {
  final String videoId;

  EditVideoPage({required this.videoId});

  @override
  _EditVideoPageState createState() => _EditVideoPageState();
}

class _EditVideoPageState extends State<EditVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  String? _privacy = 'public'; // default to public
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = []; // Ubah tipe data kategori menjadi dynamic

  final VideoService _videoService =
      VideoService(); // Instance untuk VideoService

  @override
  void initState() {
    super.initState();
    _loadVideoDetails();
  }

  Future<void> _loadVideoDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _videoService.fetchVideoForEdit(widget.videoId);

      setState(() {
        _titleController.text = data['video']['title'];
        _descriptionController.text = data['video']['description'];
        _category = data['video']['category_id'].toString();
        _privacy = data['video']['privacy'];

        // Menyimpan kategori sebagai Map dengan id dan name yang benar
        _categories = List<Map<String, dynamic>>.from(
            data['categories'].map((category) => {
                  'id': category['id'].toString(),
                  'name': category['name'],
                }));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video details: $e')));
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _videoService.updateVideo(
        videoId: widget.videoId,
        title: _titleController.text,
        description: _descriptionController.text,
        categoryId: _category!, // Mengirimkan ID kategori
        privacy: _privacy!,
      );

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Video updated successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update video: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Video'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(labelText: 'Category'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue;
                        });
                      },
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category['id'], // Menyimpan ID kategori
                          child: Text(
                            category['name'] ?? '', // Menampilkan nama kategori
                          ),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _privacy,
                      decoration: InputDecoration(labelText: 'Privacy'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _privacy = newValue;
                        });
                      },
                      items: ['public', 'private'].map((privacy) {
                        return DropdownMenuItem<String>(
                          value: privacy,
                          child: Text(privacy),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select privacy';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateVideo,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Update Video'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
