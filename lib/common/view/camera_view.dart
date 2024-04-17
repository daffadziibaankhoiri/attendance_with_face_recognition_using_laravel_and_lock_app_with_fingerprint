import 'dart:io';
import 'dart:typed_data';

import 'package:attendance_with_laravel/common/utils/extension/size_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key, required this.onImage, required this.onInputImage})
      : super(key: key);

  final Function(Uint8List image) onImage;
  final Function(InputImage inputImage) onInputImage;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  File? _image;
  ImagePicker? _imagePicker;

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            _image != null ?
            Container(
              height: 200,
              width: 200,

              decoration: BoxDecoration(
                color: Color(0xFF76ABAE),
                image: DecorationImage(
                  image: FileImage(_image!), // Menampilkan gambar
                  fit: BoxFit.cover, // Menyesuaikan gambar dengan ukuran container
                ),
                borderRadius: BorderRadius.circular(100.0), // Melengkungkan sudut
                border: Border.all(
                  color: Color(0xFFEEEEEE), // Warna border
                  width: 2.0, // Ketebalan border
                ),
              ),
            ) :  Container(
              height: 200,
              width: 200,

              decoration: BoxDecoration(
                color: Color(0xFF76ABAE),
                borderRadius: BorderRadius.circular(100.0), // Melengkungkan sudut
                border: Border.all(
                  color: Color(0xFFEEEEEE), // Warna border
                  width: 2.0, // Ketebalan border
                ),
              ),
              child: Center(
                child: Icon(Icons.tag_faces, color: Color(0xFF31363F), size: 40,),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: _getImage,
                child: Container(
                  height: 55,
                  width: 55,

                  decoration: BoxDecoration(
                    color: Color(0xFF31363F),
                    borderRadius: BorderRadius.circular(100.0), // Melengkungkan sudut
                    border: Border.all(
                      color: Color(0xFFEEEEEE), // Warna border
                      width: 2.0, // Ketebalan border
                    ),
                  ),
                  child: Icon(CupertinoIcons.camera, color: Color(0xFFEEEEEE) ,),
                ),
              ),
            ),

          ],
        ),
        // _image != null
        //     ? ClipOval(
        //   child: Container(
        //     width: 220,
        //     height: 220,
        //     decoration: BoxDecoration(
        //       color: const Color(0xFFEEEEEE), // Warna latar belakang
        //       image: DecorationImage(
        //         image: FileImage(_image!), // Menampilkan gambar
        //         fit: BoxFit.cover, // Menyesuaikan gambar dengan ukuran container
        //       ),
        //     ),
        //   ),
        // )
        //     : ClipOval(
        //   child: Container(
        //     width: 220,
        //     height: 220,
        //     color: const Color(0xFFEEEEEE),
        //     child: Center( // Menempatkan ikon di tengah
        //       child: Icon(
        //         Icons.camera_alt,
        //         size: 0.09 * MediaQuery.of(context).size.height, // contoh untuk 0.09 dari tinggi layar
        //         color: const Color(0xff2E2E2E),
        //       ),
        //     ),
        //   ),
        // ),
        // Padding(
        //   padding: const EdgeInsets.only(top: 25),
        //   child: ElevatedButton(
        //     style: ButtonStyle(
        //       backgroundColor: MaterialStateProperty.resolveWith<Color>((states){
        //         if(states.contains(MaterialState.pressed)){
        //           return Color(0xFF76ABAE);
        //         }
        //         return Color(0xFF31363F);
        //       }),
        //       foregroundColor: MaterialStateProperty.resolveWith<Color>((states){
        //         if(states.contains(MaterialState.pressed)){
        //           return Color(0xFF31363F);
        //         }
        //         return Color(0xFF76ABAE);
        //       }),
        //     ),
        //     onPressed: _getImage,
        //     child: Padding(
        //       padding: const EdgeInsets.all(1.0),
        //       child: Text(
        //         "Ambil Gambar",
        //         style: TextStyle(
        //             fontSize: 16
        //         ),
        //       ),
        //     ),
        //
        //   ),
        // ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.end,
        //   children: [
        //     Icon(
        //       Icons.camera_alt_outlined,
        //       color: Colors.white,
        //       size: 0.038.sh,
        //     ),
        //   ],
        // ),
        // SizedBox(height: 0.025.sh),
        // _image != null
        //     ? CircleAvatar(
        //   radius: 0.15.sh,
        //   backgroundColor: const Color(0xffD9D9D9),
        //   backgroundImage: FileImage(_image!),
        // )
        //     : CircleAvatar(
        //   radius: 0.15.sh,
        //   backgroundColor: const Color(0xffD9D9D9),
        //   child: Icon(
        //     Icons.camera_alt,
        //     size: 0.09.sh,
        //     color: const Color(0xff2E2E2E),
        //   ),
        // ),
        // GestureDetector(
        //   onTap: _getImage,
        //   child: Container(
        //     width: 60,
        //     height: 60,
        //     margin: const EdgeInsets.only(top: 44, bottom: 20),
        //     decoration: const BoxDecoration(
        //       gradient: RadialGradient(
        //         stops: [0.4, 0.65, 1],
        //         colors: [
        //           Color(0xffD9D9D9),
        //           Colors.white,
        //           Color(0xffD9D9D9),
        //         ],
        //       ),
        //       shape: BoxShape.circle,
        //     ),
        //   ),
        // ),
        // Text(
        //   "Click here to Capture",
        //   style: TextStyle(
        //     fontSize: 14,
        //     color: Colors.white.withOpacity(0.6),
        //   ),
        // ),
      ],
    );
  }

  Future _getImage() async {
    setState(() {
      _image = null;
    });
    final pickedFile = await    _imagePicker?.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
      // imageQuality: 50,
    );
    if (pickedFile != null) {
      _setPickedFile(pickedFile);
    }
    setState(() {});
  }

  Future _setPickedFile(XFile? pickedFile) async {
    final path = pickedFile?.path;
    if (path == null) {
      return;
    }
    setState(() {
      _image = File(path);
    });

    Uint8List imageBytes = _image!.readAsBytesSync();
    widget.onImage(imageBytes);

    InputImage inputImage = InputImage.fromFilePath(path);
    widget.onInputImage(inputImage);
  }
}
