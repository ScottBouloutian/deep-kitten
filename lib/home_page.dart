import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as Images;
import 'dart:io';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  File image;

  Future getImage() async {
    final selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      image = selectedImage;
    });
    await analyzeImage(selectedImage);
  }

  Future<Response> analyzeImage(File file) async {
    final data = await file.readAsBytes();
    final image = Images.decodeImage(data);
    final resizedImage = Images.copyResize(image, width: 256);
    final resizedImageData = Images.encodeJpg(resizedImage);
    FormData formData = new FormData.fromMap({
      "file": MultipartFile.fromBytes(resizedImageData),
    });
    try {
      final response = await Dio().post("https://tfkpb80bza.execute-api.us-east-1.amazonaws.com/dev/inference", data: formData);
      print(response);
      return response;
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Deep Kitten'),
      ),
      body: Center(
        child: Card(
          child: image == null
            ? Text('No image selected.')
            : Image.file(image)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
