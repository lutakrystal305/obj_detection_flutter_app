import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_obj_detection/tflite_flutter/recognition.dart';

import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as imageLib;

class Classifier {
  late Interpreter _interpreter;
  late List<String> _labels;

  static const String MODEL_FILE_NAME =
      'assets/ssd_mobilenet_v1_1_metadata_1.tflite';
  static const String LABEL_FILE_NAME = 'assets/ssd_mobilenet.txt';

  static const int INPUT_SIZE = 300;
  static const double THRESHOLD = 0.5;

  late ImageProcessor imageProcessor;
  late int padSize;
  late List<List<int>> _outputShapes;
  late List<TfLiteType> _outputType;
  static const int NUM_RESULTS = 10;

  Classifier({Interpreter? interpreter, List<String>? labels}) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(MODEL_FILE_NAME,
              options: InterpreterOptions()..threads = 4);
      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputType = [];
      outputTensors.forEach((element) {
        _outputShapes.add(element.shape);
        _outputType.add(element.type);
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error while creating interpreter: $e");
    }
  }

  void loadLabels({List<String>? labels}) async {
    try {
      _labels = labels ??
          await FileUtil.loadLabels(
              LABEL_FILE_NAME); // = label if label != null >< loadlabel
    } catch (e) {
      // ignore: avoid_print
      print("Error while creating interpreter: $e");
    }
  }

  TensorImage getProcessImage(TensorImage inputImage) {
    padSize = max(inputImage.height, inputImage.width);
    // ignore: prefer_conditional_assignment
    if (imageProcessor == null) {
      imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
          .build();
    }
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  Map<String, dynamic>? predict(imageLib.Image image) {
    if (_interpreter == null) {
      // ignore: avoid_print
      print('Interpreter is not initialized');
      return null;
    }
    TensorImage inputImage = TensorImage.fromImage(image);
    inputImage = getProcessImage(inputImage);

    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[2]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[3]);

    List<Object> inputs = [inputImage.buffer];
    Map<int, Object> outputs = {
      0: outputLocations.buffer,
      1: outputClasses.buffer,
      2: outputScores.buffer,
      3: numLocations.buffer
    };

    //run inference
    _interpreter.runForMultipleInputs(inputs, outputs);

    int resultCount = min(NUM_RESULTS, numLocations.getIntValue(0));

    List<Rect> locations = BoundingBoxUtils.convert(
        tensor: outputLocations,
        valueIndex: [1, 0, 3, 2],
        boundingBoxAxis: 2,
        boundingBoxType: BoundingBoxType.BOUNDARIES,
        coordinateType: CoordinateType.RATIO,
        height: INPUT_SIZE,
        width: INPUT_SIZE);
    List<Recognition> recognitions = [];
    for (int i = 0; i < resultCount; i++) {
      var score = outputScores.getDoubleValue(i);
      var labelIndex = outputClasses.getIntValue(i) + 1;
      var label = _labels.elementAt(labelIndex);

      if (score > THRESHOLD) {
        Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);
        recognitions.add(Recognition(i, label, score, transformedRect));
      }
    }
    return {"recognitions": recognitions};
  }

  Interpreter get interpreter => _interpreter;
  List<String> get labels => _labels;
}
