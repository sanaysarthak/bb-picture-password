import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPasswordScreen extends StatefulWidget {
  @override
  _VerifyPasswordScreenState createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends State<VerifyPasswordScreen> {
  File? _imageFile;
  List<String>? _savedGesture;
  List<int> _userGesture = [];
  final int _gridCount = 3;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('image_path');
    final gesture = prefs.getStringList('gesture');

    if (path != null && gesture != null) {
      setState(() {
        _imageFile = File(path);
        _savedGesture = gesture;
      });
    }
  }

  void _onGridTap(int index) {
    if (!_userGesture.contains(index)) {
      setState(() {
        _userGesture.add(index);
      });
    }
  }

  void _verifyGesture() {
    final userStr = _userGesture.map((e) => e.toString()).toList();
    if (userStr.toString() == _savedGesture.toString()) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Success'),
              content: Text('Picture password verified!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _userGesture.clear();
                    });
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text('Failed'),
              content: Text('Gesture did not match. Try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _userGesture.clear();
                    });
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFile == null || _savedGesture == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Verify Picture Password')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Verify Picture Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.file(
                    _imageFile!,
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
                                _userGesture.contains(index)
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text('Your Pattern: ${_userGesture.join(", ")}'),
            ElevatedButton.icon(
              onPressed: _verifyGesture,
              icon: Icon(Icons.check_circle),
              label: Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
