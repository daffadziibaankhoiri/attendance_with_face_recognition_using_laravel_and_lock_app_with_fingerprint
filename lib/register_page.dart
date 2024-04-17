import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:attendance_with_laravel/common/utils/extract_face_feature.dart';
import 'package:flutter/material.dart';
import 'package:attendance_with_laravel/common/view/camera_view.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:attendance_with_laravel/common/utils/extension/size_extension.dart';

import 'model/user_model.dart';
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  String? _image;
  List<FeaturePoint>? _faceFeatures = [];
  bool show = true;
  String registeruser = "";
  String registerpassword = "";
  String url_api =  "192.168.1.8:8002";
  final TextEditingController registeruserController = TextEditingController();
  final TextEditingController registerpassController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Color(0xFF222831),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 40,left: 20, right: 20, bottom: 10),
                child: Text("Register"
                  ,style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,

                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              CameraView(
                  onImage: (image){
                    setState(() {
                        _image = base64Encode(image);
                    });
                  },
                  onInputImage: (inputImage) async {
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(
                            color: Colors.greenAccent,
                          ),
                        )
                    );
                    _faceFeatures =
                        (await extractFaceFeatures(inputImage, _faceDetector));
                    setState(() {
                     Navigator.of(context).pop();
                    });
                  }
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19,left: 50, right: 50),
                child: TextField(
                  controller: registeruserController,
                  onChanged: (username){
                    setState(() {
                      registeruser = username;
                    });
                  },
                  style: const TextStyle(
                      color: Color(0xFFEEEEEE)
                  ),
                  cursorColor: Color(0xFF76ABAE),
                  decoration: InputDecoration(
                      labelText: "Username",
                      labelStyle: TextStyle(
                          color: Colors.white
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEEEEEE),width: 2.0),
                          borderRadius: BorderRadius.circular(8.0)

                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEEEEEE),width: 2.0),
                          borderRadius: BorderRadius.circular(8.0)

                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 19,left: 50, right: 50),
                child: TextField(
                  controller: registerpassController,
                  onChanged: (password){
                    setState(() {
                      registerpassword = password;
                    });
                  },
                  style: const TextStyle(
                      color: Color(0xFFEEEEEE)
                  ),
                  obscureText: show,
                  cursorColor: Color(0xFF76ABAE),
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: Icon(show ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
                          color: Color(0xFFEEEEEE),),
                        onPressed: (){
                          setState(() {
                            show = !show;
                          });
                        },
                      ),
                      labelText: "Password",
                      labelStyle: TextStyle(
                          color: Colors.white
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEEEEEE),width: 2.0),
                          borderRadius: BorderRadius.circular(8.0)

                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFEEEEEE),width: 2.0),
                          borderRadius: BorderRadius.circular(8.0)

                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFF76ABAE);
                      }
                      return Color(0xFF31363F);
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFF31363F);
                      }
                      return Color(0xFF76ABAE);
                    }),
                  ),
                  onPressed: () async {
                    UserModel register = new UserModel(
                      nama: registeruser,
                      password: registerpassword,
                      image: _image,
                      faceFeatures: _faceFeatures!.map((featurePoint) => featurePoint).toList(),
                    );
                    var url = Uri.http(url_api,"/api/register");
                    var headers = {'Content-Type': 'application/json'};
                    var response = await http.post(url, headers: headers,body: jsonEncode(register.toJson()));
                    print(response.body);
                    if(response.statusCode == 200){
                      Map<String, dynamic> responseBody = jsonDecode(response.body);
                      final snackBar = SnackBar(
                        content: Text(responseBody['message']),
                        duration: Duration(seconds: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pop();
                    }
                    print(jsonEncode(register.toJson()));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                          fontSize: 20
                      ),
                    ),
                  ),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
