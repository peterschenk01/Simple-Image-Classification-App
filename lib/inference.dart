import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as image_lib;


class Inference {
  static const modelPath = 'assets/models/mobilenet_quant.tflite';
  static const labelsPath = 'assets/models/labels.txt';

  late final Interpreter interpreter;
  late final List<String> labels;
  late Tensor inputTensor;
  late Tensor outputTensor;

  // Load model
  Future<void> _loadModel() async {
    final options = InterpreterOptions();

    // Add XNNPack and GPU delegate
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
      options.addDelegate(GpuDelegateV2());
    }

    // Add GPU delegate
    if (Platform.isIOS) {
      options.addDelegate(GpuDelegate());
    }

    // Load model from assets
    interpreter = await Interpreter.fromAsset(modelPath, options: options);
    // Get input tensor shape
    inputTensor = interpreter.getInputTensors().first;
    log(inputTensor.shape.toString());
    // Get output tensor shape
    outputTensor = interpreter.getOutputTensors().first;
    log(outputTensor.shape.toString());

    log('Interpreter loaded successfully');
  }

  // Load labels from assets
  Future<void> _loadLabels() async {
    final labelTxt = await rootBundle.loadString(labelsPath);
    labels = labelTxt.split('\n');
  }

  // Run inference on image
  Future<Map<String, double>> inference(image_lib.Image image) async {
    await _loadModel();
    await _loadLabels();

    // Resize image for model
    image_lib.Image imageInput = image_lib.copyResize(
      image,
      width: inputTensor.shape[1],
      height: inputTensor.shape[2],
    );

    // Tensor input shape
    final imageMatrix = List.generate(
        imageInput.height,
        (y) => List.generate(
          imageInput.width,
          (x) {
            final pixel = imageInput.getPixel(x, y);
            return [pixel.r, pixel.g, pixel.b];
          },
        ),
      );

    // Set tensor input [1, 224, 224, 3]
    final input = [imageMatrix];
    // Set tensor output [1, 1001]
    final output = [List<int>.filled(outputTensor.shape[1], 0)];
    
    interpreter.run(input, output);

    // Get first output tensor
    final result = output.first;
    int maxScore = result.reduce((a, b) => a + b);

    // Set classification map {label: points}
    var classification = <String, double>{};
    for (var i = 0; i < result.length; i++) {
      if (result[i] != 0) {
        // Set label: points
        classification[labels[i]] = result[i].toDouble() / maxScore.toDouble();
      }
    }

    interpreter.close();

    return classification;
  }
}