# Simple Image Classification Android App (Flutter + TensorFlow Lite)

A simple Flutter application that performs **on-device image classification** using **TensorFlow Lite**.  
The app is **Android only**.

---

## Download

[**Latest APK Release**](https://github.com/peterschenk01/Simple-Image-Classification-App/releases/latest)

## Features

- Select an image and classify it locally on the device
- Offline inference using a quantized MobileNet TensorFlow Lite classification model

---

## Tech Stack

- **Flutter** (Dart)
- **TensorFlow Lite**

---

## Project Structure

- `lib/` — Flutter application source code
- `assets/` — TensorFlow Lite model and label files
- `android/` — Android configuration and build files

## Getting Started

### Prerequisites

- Flutter SDK
- Android Studio
- Android device or emulator

Check your environment:

```bash
flutter doctor
```

Install Dependencies:

``` bash
flutter pub get
```

Run the App:

``` bash
flutter run
```