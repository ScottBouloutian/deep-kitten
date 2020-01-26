import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as Images;
import 'dart:convert';
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Uint8List inputImage;
  Uint8List outputImage;

  int mapColor(int color) {
    final red = Images.getRed(color);
    switch (red) {
      case 1:
        return Images.setRed(color, 255);
      case 2:
        return Images.setGreen(color, 255);
      case 3:
        return Images.setBlue(color, 255);
      default:
        print(red);
        return 0;
    }
  }

  Future getImage() async {
    final selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    final resizedImage = await resizeImage(selectedImage);
    final resizedJpg = Images.encodeJpg(resizedImage);
    setState(() {
      inputImage = resizedJpg;
    });
    final response = await analyzeImage(resizedJpg);
    final output = base64Decode(response.data);
    final decodedOutput = Images.decodePng(output);
    for (int y = 0; y < decodedOutput.height; y++) {
      for (int x = 0; x < decodedOutput.width; x++) {
        final color = decodedOutput.getPixel(x, y);
        final updatedColor = mapColor(color);
        decodedOutput.setPixel(x, y, updatedColor);
      }
    }
    final colorizedImage = Images.encodeJpg(decodedOutput);
    setState(() {
      outputImage = colorizedImage;
    });
  }

  Future<Images.Image> resizeImage(File file) async {
    final data = await file.readAsBytes();
    final image = Images.decodeImage(data);
    return Images.copyResize(image, width: 512);
  }

  Future<Response> analyzeImage(Uint8List image) async {
    FormData formData = new FormData.fromMap({
      'file': MultipartFile.fromBytes(image),
    });
    return await Dio().post(
      'https://tfkpb80bza.execute-api.us-east-1.amazonaws.com/dev/inference',
      data: formData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deep Kitten'),
      ),
      body: ListView(
        children: [
          Card(
            child: inputImage == null
              ? Text('No image selected.')
              : Image.memory(inputImage)
          ),
          Card(
            child: outputImage == null
              ? Text('No image selected.')
              : Image.memory(outputImage)
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
