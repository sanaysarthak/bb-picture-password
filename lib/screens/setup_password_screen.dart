import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class SetupPasswordScreen extends StatefulWidget {
  @override
  _SetupPasswordScreenState createState() => _SetupPasswordScreenState();
}

class _SetupPasswordScreenState extends State<SetupPasswordScreen> {
  File? _selectedImage;
  final List<int> _gesture = [];
  final int _gridCount = 3;

  Future<void> _pickImage() async {
    await Permission.photos.request();
    await Permission.storage.request();

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _gesture.clear(); // reset gesture when new image picked
      });
    }
  }

  void _onGridTap(int index) {
    if (!_gesture.contains(index)) {
      setState(() {
        _gesture.add(index);
      });
    }
  }

  Future<void> _saveGesture() async {
    if (_gesture.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please tap at least 3 points!')));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'gesture',
      _gesture.map((e) => e.toString()).toList(),
    );
    if (_selectedImage != null) {
      await prefs.setString('image_path', _selectedImage!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Picture password saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Picture Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _selectedImage == null
                ? ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text('Pick Image from Gallery'),
                )
                : Expanded(
                  child: Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      GridView.builder(
                        itemCount: _gridCount * _gridCount,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _gridCount,
                        ),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _onGridTap(index),
                            child: Container(
                              margin: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                color:
                                    _gesture.contains(index)
                                        ? Colors.blue.withOpacity(0.5)
                                        : Colors.transparent,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
            SizedBox(height: 12),
            if (_selectedImage != null)
              Column(
                children: [
                  Text('Tapped Points: ${_gesture.join(", ")}'),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _saveGesture,
                    icon: Icon(Icons.save),
                    label: Text('Save Picture Password'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
