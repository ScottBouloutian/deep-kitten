import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:image/image.dart' as image;
import 'package:video_player/video_player.dart';
import 'dart:convert';
import 'dart:io';
import 'loading_video.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Uint8List inputImage;
  Uint8List outputImage;
  Uint8List overlayImage;
  VideoPlayerController controller;
  Future<void> initializeVideo;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.asset('assets/videos/loading-cat.mp4');
    controller.setLooping(true);
    initializeVideo = controller.initialize().then((_) {
      controller.play();
    });
  }

  image.Image createColorCodedImage(image.Image dataImage) {
    final result = image.Image.from(dataImage);
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final color = result.getPixel(x, y);
        final red = image.getRed(color);
        var resultColor;
        switch (red) {
          case 1:
            resultColor = image.setRed(color, 255);
            break;
          case 2:
            resultColor = image.setGreen(color, 255);
            break;
          case 3:
            resultColor = image.setBlue(color, 255);
            break;
          default:
            resultColor = color;
        }
        result.setPixel(x, y, resultColor);
      }
    }
    return result;
  }

  image.Image createOverlayImage(image.Image baseImage, image.Image dataImage) {
    final result = image.Image.from(baseImage);
    for (int y = 0; y < result.height; y++) {
      for (int x = 0; x < result.width; x++) {
        final baseColor = baseImage.getPixel(x, y);
        final dataColor = dataImage.getPixel(x, y);
        final red = image.getRed(dataColor);
        var resultColor;
        switch (red) {
          case 1:
            resultColor = image.setRed(baseColor, 255);
            break;
          case 2:
            resultColor = image.setGreen(baseColor, 255);
            break;
          case 3:
            resultColor = image.setBlue(baseColor, 255);
            break;
          default:
            resultColor = baseColor;
        }
        result.setPixel(x, y, resultColor);
      }
    }
    return result;
  }

  Future getImage() async {
    setState(() {
      inputImage = null;
      outputImage = null;
      overlayImage = null;
    });
    final selectedImage = await ImagePicker.pickImage(source: ImageSource.camera);
    final resizedImage = await resizeImage(selectedImage);
    final resizedJpg = image.encodeJpg(resizedImage);
    setState(() {
      inputImage = resizedJpg;
    });
    final response = await analyzeImage(resizedJpg);
    final output = base64Decode(response.data);
    final dataImage = image.decodePng(output);
    final colorCodedImage = createColorCodedImage(dataImage);
    final colorizedImage = image.encodeJpg(colorCodedImage);
    setState(() {
      outputImage = colorizedImage;
    });
    final averageImage = createOverlayImage(resizedImage, dataImage);
    setState(() {
      overlayImage = image.encodeJpg(averageImage);
    });
  }

  Future<image.Image> resizeImage(File file) async {
    final data = await file.readAsBytes();
    final decodedImage = image.decodeImage(data);
    return image.copyResize(decodedImage, width: 512);
  }

  Future<Response> analyzeImage(Uint8List image) async {
    FormData formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(image),
    });
    return await Dio().post(
      'https://tfkpb80bza.execute-api.us-east-1.amazonaws.com/dev/inference',
      data: formData,
    );
  }

  Widget buildOutputImage() {
    if (inputImage == null) {
      return Container();
    } else if (outputImage == null) {
      return Container(
        color: const Color(0xFF9BDFFF),
        child: Center(
          child: LoadingVideo(
            controller: controller,
            future: initializeVideo,
          ),
        )
      );
    } else {
      return Image.memory(outputImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    controller.play();
    return Scaffold(
      appBar: AppBar(
        title: Text('Deep Kitten'),
      ),
      body: ListView(
        children: [
          inputImage == null
            ? Container()
            : Image.memory(inputImage),
          buildOutputImage(),
          overlayImage == null
            ? Container()
            : Image.memory(overlayImage),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
