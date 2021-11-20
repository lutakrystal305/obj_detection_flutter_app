import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_obj_detection/tflite/home_page.dart';
import 'package:flutter_obj_detection/tflite/static_img.dart';
import 'package:flutter_obj_detection/ui/home_view.dart';
import 'package:tflite/tflite.dart';

late List<CameraDescription> cameras;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Object Detection'),
        leading: IconButton(
          icon: const Icon(Icons.access_alarms_outlined),
          onPressed: () {},
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonTheme(
                minWidth: 170.0,
                child: ElevatedButton(
                  child: const Text('Dectector on an image'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StaticImage()));
                  },
                )),
            ButtonTheme(
                minWidth: 170.0,
                child: ElevatedButton(
                  child: const Text('Real time detector'),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePage(cameras)));
                  },
                ))
          ],
        ),
      ),
    );
  }
}
