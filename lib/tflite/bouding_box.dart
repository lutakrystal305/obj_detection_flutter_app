// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'dart:math' as math;

//import 'package:flutter_tts/flutter_tts.dart';

class BoundingBox extends StatelessWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;

  // FlutterTts flutterTts = FlutterTts();
  // Future speak(String a) async {
  //   var result = await flutterTts.speak(a);
  //   // ignore: avoid_print
  //   print(a);
  // }

  // ignore: use_key_in_widget_constructors, prefer_const_constructors_in_immutables
  BoundingBox(
    this.results,
    this.previewH,
    this.previewW,
    this.screenH,
    this.screenW,
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBox() {
      return results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        var scaleW, scaleH, x, y, w, h;

        if (screenH / screenW > previewH / previewW) {
          scaleW = screenH / previewH * previewW;
          scaleH = screenH;
          var difW = (scaleW - screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = screenW / previewW * previewH;
          scaleW = screenW;
          var difH = (scaleH - screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        // if (re['confidenceInClass'] > 0.6) {
        //   String a = '';
        //   double centerX = (x + w) / 2;
        //   double centerY = (y + h) / 2;
        //   if (centerX / screenW > 0.7) {
        //     if (centerY / screenH > 0.6) {
        //       a = re['detectedClass'] + "is locate in four o'clock direction";
        //     } else if (centerY / screenH > 0.4) {
        //       a = re['detectedClass'] + "is locate in two o'clock direction";
        //     } else {
        //       a = re['detectedClass'] + "is locate in three o'clock direction";
        //     }
        //   } else if (centerX / screenW < 0.4) {
        //     if (centerY / screenH > 0.6) {
        //       a = re['detectedClass'] + "is locate in sevent o'clock direction";
        //     } else if (centerY / screenH > 0.4) {
        //       a = re['detectedClass'] + "is locate in eleven o'clock direction";
        //     } else {
        //       a = re['detectedClass'] + "is locate in nine o'clock direction";
        //     }
        //   }
        //   speak(a);
        // }

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      children: _renderBox(),
    );
  }
}
