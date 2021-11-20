import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_obj_detection/tflite/bouding_box.dart';
import 'package:flutter_obj_detection/tflite/camera_feed.dart';
//import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  // ignore: use_key_in_widget_constructors
  const HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  initCameras() async {}
  loadTfModel() async {
    // ignore: avoid_print
    print('load model1');
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet_v1_1_metadata_1.tflite",
      labels: "assets/ssd_mobilenet.txt",
    );
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  void initState() {
    super.initState();
    //speak();
    loadTfModel();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('real time'),
        ),
        // ignore: avoid_unnecessary_containers
        body: Container(
          child: Stack(
            children: [
              CameraFeed(widget.cameras, setRecognitions),
              // ignore: unnecessary_null_comparison
              _recognitions != null
                  ? BoundingBox(
                      _recognitions,
                      max(_imageHeight, _imageWidth),
                      min(_imageHeight, _imageWidth),
                      screen.height,
                      screen.width)
                  : const Text('')
            ],
          ),
        ));
  }
}
