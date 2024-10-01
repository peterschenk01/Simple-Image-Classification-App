import 'package:flutter/material.dart';

void displaySnackbar(String text, BuildContext context) {  
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        behavior: SnackBarBehavior.floating,
        content: Container(
          alignment: Alignment.center,
          child: Card(
            color: const Color.fromARGB(255, 40, 40, 40),
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Text(
                text,
                // Snackbar is as long as the longest line of text
                textWidthBasis: TextWidthBasis.longestLine,
                // Text is centered
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          )
        )
      )
    );
  }