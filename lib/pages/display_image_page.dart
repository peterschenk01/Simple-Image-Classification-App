import 'dart:io';
import 'package:image_classification_app/inference.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:photo_view/photo_view.dart';
import 'package:image_classification_app/global.dart';
import 'package:image/image.dart' as image_lib;

// New Page where the image is displayed
class DisplayImagePage extends StatefulWidget {
  
  final File image;

  const DisplayImagePage({super.key, required this.image});

  @override
  State<DisplayImagePage> createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {

  Map<String, double>? classification;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Selected Image",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.black,
            color: Colors.white,
            onSelected: (String value) async {
              switch (value) {
                // Save image to gallery
                case "Save image to gallery":
                  if (await Gal.requestAccess(toAlbum: true)) {
                    await Gal.putImage(widget.image.path, album: "CLIPascene");

                    if (context.mounted) {
                      displaySnackbar("Image saved to gallery.", context);
                    }
                  }
                  else {
                    if (context.mounted){
                      displaySnackbar("Permission to save to gallery not granted. Please check app permission settings.", context);
                    }
                  }
                  break;
                // Run inference on the image
                case "Inference":
                  final Inference inference = Inference();
                  final imageData = widget.image.readAsBytesSync();
                  image_lib.Image? img = image_lib.decodeImage(imageData);
                  setState(() {});
                  classification = await inference.inference(img!);
                  setState(() {});

                  break;
              }
            },
            itemBuilder: (context) {
              return {"Save image to gallery", "Inference"}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ]
      ),

      body: Column(
        children: [
          // Display Image
          Expanded(child: PhotoView(
            imageProvider: FileImage(widget.image),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.contained * 4,
            backgroundDecoration: const BoxDecoration(color: Colors.white),
            )
          ),
          // Show classification result
          SingleChildScrollView(
            child: Column(
              children: [
                if (classification != null)
                  ...(classification!.entries.toList()
                        ..sort(
                          (a, b) => a.value.compareTo(b.value),
                        ))
                      .reversed
                      .take(3)
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.white,
                          child: Row(
                            children: [
                              Text(e.key),
                              const Spacer(),
                              Text(e.value.toStringAsFixed(2))
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
          ]
      )
    );
  }
}