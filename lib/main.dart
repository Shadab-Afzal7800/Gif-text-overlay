import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart' hide ImageSource;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 2;
  ImageProvider? provider;
  Uint8List? gifData1;
  Uint8List? gifData2;
  String text1 = '';
  String text2 = '';
  Uint8List? resultImageBytes;
  late TextEditingController _controller1, _controller2;
  @override
  void initState() {
    super.initState();
    _controller1 = TextEditingController();
    _controller2 = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'merge',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
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
                    controller: _controller1,
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
                    controller: _controller2,
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
            buildImageResult(),
          ],
        ),
      ),
    );
  }

  Future addText(String text, Offset offset) async {
    const int size = 56;
    final ImageEditorOption option = ImageEditorOption();
    final AddTextOption textOption = AddTextOption();
    textOption.addText(
      EditorText(
        offset: offset,
        text: text,
        fontSizePx: size,
        textColor: const Color(0xFF995555),
      ),
    );
    option.outputFormat = const OutputFormat.png();

    option.addOption(textOption);

    final Uint8List u = resultImageBytes!;
    final Uint8List? result = await ImageEditor.editImage(
      image: u,
      imageEditorOption: option,
    );
    print(option.toString());

    if (result == null) {
      return;
    }
    resultImageBytes = result;
    provider = MemoryImage(result);
    setState(() {});
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
        child: FittedBox(fit: BoxFit.contain, child: Image(image: provider!)),
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
          Offset(0, 0),
          Size.square(slideLength),
        ),
      ),
    );

    option.addImage(
      MergeImageConfig(
        image: MemoryImageSource(gifData2!),
        position: const ImagePosition(
          Offset(0, slideLength),
          Size.square(slideLength),
        ),
      ),
    );

    final Uint8List? result = await ImageMerger.mergeToMemory(option: option);
    if (result == null) {
      provider = null;
    } else {
      resultImageBytes = result;
      provider = MemoryImage(result);
    }
    print(const Offset(slideLength, slideLength));
    addText(_controller1.text, const Offset(slideLength, slideLength / 3)).then(
        (value) => addText(_controller2.text,
                const Offset(slideLength, slideLength * 1.25))
            .then((value) => setState(() {})));
  }
}
