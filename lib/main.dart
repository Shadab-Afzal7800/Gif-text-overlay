import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    home: MyApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? gifData1;
  Uint8List? gifData2;
  String text1 = '';
  String text2 = '';

  Future<void> _pickGif(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        if (index == 1) {
          gifData1 = bytes.buffer.asUint8List();
        } else {
          gifData2 = bytes.buffer.asUint8List();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combine GIFs and Text'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _pickGif(1),
                child: gifData1 != null
                    ? Image.memory(gifData1!, width: 150, height: 150)
                    : Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add, size: 50),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      text1 = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Text 1',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => _pickGif(2),
                child: gifData2 != null
                    ? Image.memory(gifData2!, width: 150, height: 150)
                    : Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[200],
                        child: const Icon(Icons.add, size: 50),
                      ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      text2 = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter Text 2',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _combineAndDisplayImages(context);
            },
            child: const Text('Combine and Display'),
          ),
        ],
      ),
    );
  }

  Future<void> _combineAndDisplayImages(BuildContext context) async {
    if (gifData1 == null || gifData2 == null) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select both GIF files.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Combine the GIF files and texts into one image
    final byteData = Uint8List.view(await _channel.invokeMethod(
      'combineImages',
      {
        'gifData1': gifData1,
        'gifData2': gifData2,
        'text1': text1,
        'text2': text2,
      },
    ))
        .buffer;
    final combinedImageData = byteData.buffer;
    // Display the combined image in an AlertDialog
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Combined Image'),
          content: Center(
            child: combinedImageData != null
                ? Image.memory(combinedImageData)
                : const Text('Failed to combine images.'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static const MethodChannel _channel = MethodChannel('combine_images');
}
