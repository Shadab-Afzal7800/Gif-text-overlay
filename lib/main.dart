import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart' hide ImageSource;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(home: MergeImagePage()));
}

class MergeImagePage extends StatefulWidget {
  const MergeImagePage({super.key});

  @override
  _MergeImagePageState createState() => _MergeImagePageState();
}

class _MergeImagePageState extends State<MergeImagePage> {
  int count = 2;
  ImageProvider? provider;
  Uint8List? gifData1;
  Uint8List? gifData2;
  String text1 = '';
  String text2 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'merge',
        ),
      ),
      body: Column(
        children: <Widget>[
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
          TextButton(
            onPressed: _merge,
            child: const Text('merge'),
          ),
          Slider(
            value: count.toDouble(),
            divisions: 4,
            label: 'count : $count',
            min: 2,
            max: 6,
            onChanged: (double v) {
              count = v.toInt();
              setState(() {});
            },
          ),
          buildImageResult(),
        ],
      ),
    );
  }

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

  Widget buildImageResult() {
    if (provider != null) {
      return SizedBox(
        width: 300,
        height: 300,
        child: Image(image: provider!),
      );
    }
    return Container();
  }

  Future<void> _merge() async {
    const double slideLength = 180.0;
    final ImageMergeOption option = ImageMergeOption(
      canvasSize: Size(slideLength * count, slideLength * count),
      format: const OutputFormat.png(),
    );

    option.addImage(
      MergeImageConfig(
        image: MemoryImageSource(gifData1!),
        position: const ImagePosition(
          Offset(0, slideLength),
          Size.square(slideLength),
        ),
      ),
    );

    option.addImage(
      MergeImageConfig(
        image: MemoryImageSource(gifData2!),
        position: const ImagePosition(
          Offset(1, 1),
          Size.square(slideLength),
        ),
      ),
    );

    final Uint8List? result = await ImageMerger.mergeToMemory(option: option);
    if (result == null) {
      provider = null;
    } else {
      provider = MemoryImage(result);
    }
    setState(() {});
  }
}
