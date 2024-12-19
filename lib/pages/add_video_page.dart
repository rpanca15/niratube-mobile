import 'dart:html' as html;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import '../services/video_service.dart';
import 'package:file_picker/file_picker.dart';
import '../models/category_model.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _category;
  String? _privacy = 'public';
  String? _videoPath;
  String? _base64Video;
  bool _isUploading = false;
  bool _isLoadingCategories = true;
  List<Category> _categories = []; // List of Category objects

  final VideoService _videoService =
      VideoService(); // Instance for VideoService

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Function to load categories from the server
  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    try {
      final categories =
          await _videoService.fetchCategories(); // Fetch categories
      setState(() {
        _categories = categories; // Update the category list
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
      print('Error: $e');
    } finally {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickVideo() async {
    if (kIsWeb) {
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement()
            ..accept = 'video/*' // Hanya video
            ..click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;
        final videoFile = files[0];

        // Convert to base64
        final reader = html.FileReader();
        reader.readAsArrayBuffer(videoFile);

        reader.onLoadEnd.listen((e) {
          final result = reader.result as List<int>;
          final base64String = base64Encode(result);
          setState(() {
            _videoPath = videoFile.name;
            _base64Video = base64String;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Video selected: ${videoFile.name}')),
          );
        });
      });
    } else {
      // Jika bukan web, menggunakan `file_picker` seperti biasa
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _videoPath = result.files.single.path;
          _base64Video = base64String;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Video selected: ${result.files.single.name}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video selected')),
        );
      }
    }
  }

  Future<void> _submitVideo() async {
    if (_formKey.currentState!.validate()) {
      if (_base64Video == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a video')),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      try {
        await _videoService.addVideo(
          base64Video: _base64Video!,
          title: _titleController.text,
          description: _descriptionController.text,
          categoryId: _category!, // Passing category ID
          privacy: _privacy!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        print('Error: $e');
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Video'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Video Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  if (value.length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description is required';
                  }
                  if (value.length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Dropdown for category
              _isLoadingCategories
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue;
                        });
                      },
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id.toString(), // Use category ID
                          child: Text(category.name), // Display category name
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _privacy,
                decoration: const InputDecoration(
                  labelText: 'Privacy',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (value) {
                  setState(() {
                    _privacy = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Privacy is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickVideo,
                child: const Text('Select Video'),
              ),
              if (_videoPath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Selected: $_videoPath'),
                ),
              const SizedBox(height: 16),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitVideo,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
