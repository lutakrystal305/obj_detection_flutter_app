//import 'dart:html';
// ignore_for_file: unnecessary_null_comparison, avoid_unnecessary_containers
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
//import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:text_to_speech/text_to_speech.dart';
import 'package:tflite/tflite.dart';

class StaticImage extends StatefulWidget {
  const StaticImage({Key? key}) : super(key: key);

  @override
  _StaticImageState createState() => _StaticImageState();
}

class _StaticImageState extends State<StaticImage> {
  //FlutterTts flutterTts = FlutterTts();
  //TextToSpeech tts = TextToSpeech();

  // Future speak(String a) async {
  //   await flutterTts.getEngines;

  //   return await flutterTts.speak(a);
  //   // ignore: avoid_print
  // }

  late File _img = File('');
  late List _recognitions = [];
  late bool _pusy = false;
  late double _imgW = 0, _imgH = 0;

  final picker = ImagePicker();

  loadModel() async {
    // ignore: avoid_print
    print('load model');
    await Tflite.loadModel(
        model: 'assets/ssd_mobilenet_v1_1_metadata_1.tflite',
        labels: 'assets/ssd_mobilenet.txt');
  }

  detectObj(File img) async {
    var recognitions = await Tflite.detectObjectOnImage(
        path: img.path,
        model: 'SSDMobileNet',
        imageMean: 127.5,
        imageStd: 127.5,
        threshold: 0.4,
        numResultsPerClass: 10,
        asynch: true);
    FileImage(img)
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imgW = info.image.width.toDouble();
        _imgH = info.image.height.toDouble();
      });
    }));
    setState(() {
      _recognitions = recognitions!;
    });
  }

  // Future initTTS() async {
  //   flutterTts.setErrorHandler((message) async {
  //     // ignore: avoid_print
  //     print(message);
  //   });

  //   await flutterTts.getLanguages;
  //   await flutterTts.getVoices;
  //   await flutterTts.setLanguage("en-US");
  //   await flutterTts.setQueueMode(1);
  // }

  @override
  void initState() {
    super.initState();
    _pusy = true;
    loadModel().then((val) {
      setState(() {
        _pusy = false;
      });
    });
    //initTTS();
    //speak('welcome!');
  }

  List<Widget> renderBox(Size screen) {
    // ignore: unnecessary_null_comparison
    if (_recognitions == null) return [];
    if (_imgW == null || _imgH == null) return [];

    double factorX = screen.width;
    double factorY = _imgH / _imgH * screen.width;

    // ignore: avoid_print
    print(factorX);
    // ignore: avoid_print
    print(factorY);

    Color green = Colors.green;

    // ignore: avoid_unnecessary_containers
    return _recognitions
        // ignore: avoid_unnecessary_containers
        .map((x) {
      // ignore: avoid_print
      print(x);
      // if (x['confidenceInClass'] > 0.6) {
      //   String a = '';
      //   double center_x =
      //       (x['rect']['x'] * factorX + x['rect']['w'] * factorX) / 2;
      //   double center_y =
      //       (x['rect']['y'] * factorY + x['rect']['h'] * factorY) / 2;
      //   if (center_x / screen.width > 0.7) {
      //     if (center_y / screen.height > 0.6) {
      //       a = x['detectedClass'] + "is locate in four o'clock direction";
      //     } else if (center_y / screen.height > 0.4) {
      //       a = x['detectedClass'] + "is locate in two o'clock direction";
      //     } else {
      //       a = x['detectedClass'] + "is locate in three o'clock direction";
      //     }
      //   } else if (center_x / screen.width < 0.4) {
      //     if (center_y / screen.height > 0.6) {
      //       a = x['detectedClass'] + "is locate in sevent o'clock direction";
      //     } else if (center_y / screen.height > 0.4) {
      //       a = x['detectedClass'] + "is locate in eleven o'clock direction";
      //     } else {
      //       a = x['detectedClass'] + "is locate in nine o'clock direction";
      //     }
      //   } else {
      //     a = x['detectedClass'] + ' is locate in center of view';
      //   }
      //   // ignore: avoid_print
      //   print(a);
      //   speak(a);
      // }
      return Container(
        child: Positioned(
            left: x['rect']['x'] * factorX,
            top: x['rect']['y'] * factorY,
            width: x['rect']['w'] * factorX,
            height: x['rect']['h'] * factorY,
            child: (x['confidenceInClass'] > 0.5)
                ? Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: green,
                      width: 3,
                    )),
                    child: Text(
                        "${x['detectedClass']} : ${(x['confidenceInClass'] * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                            background: Paint()..color = green,
                            color: Colors.white,
                            fontSize: 15)))
                : Container()),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<Widget> stackChildren = [];

    stackChildren.add(Positioned(
        child: _img == null
            // ignore: avoid_unnecessary_containers
            ? Container(
                child: const Text(
                'Please select an image!',
                style: TextStyle(color: Colors.white),
              ))
            : Container(
                child: Image.file(_img),
              )));
    stackChildren.addAll(renderBox(size));

    if (_pusy) {
      stackChildren.add(const Center(
        child: CircularProgressIndicator(),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object detection on gallery'),
        leading: IconButton(
            onPressed: () async {
              // ignore: avoid_print
              //String text = "Hello, Good Morning!";
              //tts.speak(text);
              print('vlxx');
              // return await flutterTts
              //     .speak('hello')
              //     .whenComplete(() => print('done'))
              //     .onError((error, stackTrace) => print(error));
              //speak('hello');
            },
            icon: const Icon(Icons.ice_skating)),
      ),
      body: Container(
        alignment: Alignment.center,
        child: stackChildren != null
            ? Stack(
                children: stackChildren,
              )
            : const Center(child: Text('hallo')),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: getImageFromCamera,
            heroTag: 'button1',
            child: const Icon(Icons.camera_alt),
          ),
          FloatingActionButton(
            onPressed: getImageFromGallery,
            heroTag: 'button2',
            child: const Icon(Icons.photo),
          )
        ],
      ),
    );
  }

  Future getImageFromCamera() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _img = File(pickedFile.path);
      } else {
        // ignore: avoid_print
        print('No image selected!');
      }
    });
    detectObj(_img);
  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _img = File(pickedFile.path);
      } else {
        // ignore: avoid_print
        print('No image selected!');
      }
    });
    detectObj(_img);
  }
}
