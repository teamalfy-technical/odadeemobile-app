import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:odadee/components/photos/common_buttons.dart';

import 'select_photo_options_screen.dart';

class SetPhotoScreen extends StatefulWidget {
  const SetPhotoScreen({super.key});

  static const id = 'set_photo_screen';

  @override
  State<SetPhotoScreen> createState() => _SetPhotoScreenState();
}

class _SetPhotoScreenState extends State<SetPhotoScreen> {
  XFile? _pickedFile;

  Future _pickImage(ImageSource source) async {
    try {
      // On web, camera is not supported, show a message
      if (kIsWeb && source == ImageSource.camera) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera is not available on web. Please use gallery instead.'),
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      final image = await ImagePicker().pickImage(source: source);

      // Check if widget is still mounted after file picker
      if (!mounted) return;
      if (image == null) return;

      if (kIsWeb) {
        // On web, just use the XFile directly
        if (mounted) {
          setState(() {
            _pickedFile = image;
          });
          Navigator.of(context).pop();
        }
      } else {
        // On mobile, crop the image
        final croppedFile = await _cropImage(imageFile: image);
        if (mounted) {
          setState(() {
            _pickedFile = croppedFile ?? image;
          });
          Navigator.of(context).pop();
        }
      }
    } on PlatformException catch (e) {
      debugPrint('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Failed to pick image: ${e.message ?? "Unknown error"}'),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<XFile?> _cropImage({required XFile imageFile}) async {
    // Image cropper might not work on web, skip cropping
    if (kIsWeb) return imageFile;

    CroppedFile? croppedImage =
        await ImageCropper().cropImage(sourcePath: imageFile.path);
    if (croppedImage == null) return null;
    return XFile(croppedImage.path);
  }

  void _showSelectPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.28,
          maxChildSize: 0.4,
          minChildSize: 0.28,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: SelectPhotoOptionsScreen(
                onTap: _pickImage,
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Set a photo of yourself',
                        //style: kHeadTextStyle,
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Photos make your profile more engaging',
                        // style: kHeadSubtitleTextStyle,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _showSelectPhotoOptions(context);
                    },
                    child: Center(
                      child: Container(
                          height: 200.0,
                          width: 200.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: Center(
                            child: _pickedFile == null
                                ? const Text(
                                    'No image selected',
                                    style: TextStyle(fontSize: 20),
                                  )
                                : FutureBuilder<Uint8List>(
                                    future: _pickedFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return CircleAvatar(
                                          backgroundImage:
                                              MemoryImage(snapshot.data!),
                                          radius: 200.0,
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                          )),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Anonymous',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CommonButtons(
                    onTap: () => _showSelectPhotoOptions(context),
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    textLabel: 'Add a Photo',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
