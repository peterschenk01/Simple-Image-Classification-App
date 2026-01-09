import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_classification_app/pages/display_image_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_classification_app/global.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Image Classification",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Button to choose image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(20.0)),
                  backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 240, 240, 240)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))),
                ),
                icon: const Icon(
                  Icons.add_a_photo,
                  color: Color.fromARGB(255, 20, 20, 20),
                  size: 50
                  ),
                label: const Text(
                  "Choose image",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                  ),
                // Choose between gallery and camera
                onPressed: () => showOptions(context),
              ),
            ), 

            // Button to show last image
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                style: const ButtonStyle(
                  padding: WidgetStatePropertyAll(EdgeInsets.all(20.0)),
                  backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 240, 240, 240)),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30.0)))),
                ),
                icon: const Icon(
                  Icons.insert_photo,
                  color: Color.fromARGB(255, 20, 20, 20),
                  size: 50
                  ),
                label: const Text(
                  "Show last image",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                  ),
                onPressed:() {
                  if(image != null){
                    navigateToDisplayImagePage();
                  } else {
                    displaySnackbar("No image selected since app was opened.", context);
                  }
                },
              ),
            ), 
          ],
        ),
      ),
    );
  }

  // Function to pick an image from source (either gallery or camera), crop it and display it on a new page
  Future<void> pickandCropImage(ImageSource source) async {

    // Choose image from gallery or camera
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile == null) return;
    
    // Crop image
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      //maxWidth: 500,
      //maxHeight: 500,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      //aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );

    if (croppedFile == null) return;
    
    setState(() {
      image = File(croppedFile.path);
    });
    
    // Display image on new page
    navigateToDisplayImagePage();
  }

  // Pop-up to choose between camera or gallery
  void showOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (childContext) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text(
              "Photo Gallery",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () {
              // Close the options modal
              Navigator.of(childContext).pop();
              // Get image from gallery
              pickandCropImage(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text(
              "Camera",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: () async {
              // Close the options modal
              Navigator.of(childContext).pop();
              // Get image from camera
              if(await Permission.camera.request().isGranted){
                pickandCropImage(ImageSource.camera);
              } else {
                if (context.mounted) {
                  displaySnackbar("Camera permission not granted. Please check app permission settings.", context);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  // Open new page where image is displayed
  void navigateToDisplayImagePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayImagePage(image: image!),
      ),
    );
  }

}