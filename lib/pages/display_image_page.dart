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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(
              onPressed: _runClassification,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text("Classify"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            iconColor: Colors.black,
            color: Colors.white,
            onSelected: (value) async {
              if (value == "Save image to gallery") {
                if (await Gal.requestAccess(toAlbum: true)) {
                  await Gal.putImage(widget.image.path, album: "CLIPascene");
                  if (context.mounted) {
                    displaySnackbar("Image saved to gallery.", context);
                  }
                } else {
                  if (context.mounted) {
                    displaySnackbar(
                      "Permission to save to gallery not granted. Please check app permission settings.",
                      context,
                    );
                  }
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: "Save image to gallery",
                child: Text("Save image to gallery"),
              ),
            ],
          ),
        ],
      ),

      body: Stack(
        children: [
          Positioned.fill(
            child: PhotoView(
              imageProvider: FileImage(widget.image),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.contained * 4,
              backgroundDecoration: const BoxDecoration(color: Colors.white),
            ),
          ),
          if (classification != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      (classification!.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value)))
                          .take(3)
                          .map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(child: Text(e.key)),
                                  Text(e.value.toStringAsFixed(2)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _runClassification() async {
    final inference = Inference();
    final imageData = widget.image.readAsBytesSync();
    final img = image_lib.decodeImage(imageData);

    if (img == null) return;

    setState(() => classification = null); // optional: clear old result
    final result = await inference.inference(img);
    if (!mounted) return;

    setState(() => classification = result);
  }
}
