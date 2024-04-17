import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:attendance_with_laravel/model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:attendance_with_laravel/common/view/camera_view.dart';
import 'package:attendance_with_laravel/common/utils/extract_face_feature.dart';
import 'dart:math' as math;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter_face_api/face_api.dart' as regula;
import 'package:lottie/lottie.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:geolocator_android/geolocator_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'package:geolocator_android/geolocator_android.dart'
    show AndroidSettings, ForegroundNotificationConfig, AndroidResource;

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );
  String? user_id;
  Future<void> getId () async{
    final simpanan = await SharedPreferences.getInstance();
    user_id = simpanan.getString('user_id');
    print("ini adalah id user $user_id");
  }
  String LokasiSekarang = "";
  Future<void> dapatkanLokasi(BuildContext context) async{
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Layanan lokasi tidak diaktifkan"))
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Izin lokasi tidak diberikan"))
        );
        return;
      }
    }
    if(permission == LocationPermission.deniedForever){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Izin lokasi ditolak selamanya"))
      );
      return;
    }
    setState((){
      LokasiSekarang = "Sedang Mendapatkan Lokasi Sekarang...";
    });
    print("Lokasi Sekarang : $LokasiSekarang");

    // LokasiSekarang = "Sedang Mendapatkan Lokasi Sekarang...";
    Position position = await Geolocator.getCurrentPosition();
    print(position);
    try{
      List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemark[0];
      var jalan = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
      // print(jalan);
      setState((){
        LokasiSekarang = jalan;
      });
      // LokasiSekarang = jalan;
      print("Lokasi Sekarang : $LokasiSekarang");
    }catch(e){
      print("terjadi kesalahan : $e");
    }
  }
  List<FeaturePoint>? _faceFeatures = [];
  var image1 = regula.MatchFacesImage();
  var image2 = regula.MatchFacesImage();
  String _similarity = "";
  bool _canAuthenticate = false;
  List<UserModel> users = [];
  bool userExists = false;
  UserModel? loggingUser;
  bool isMatching = false;
  int trialNumber = 1;
  String cocok = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Color(0xFF222831),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Align(
                    alignment: Alignment.center,
                    child: CameraView(
                        onImage: (image){
                          _setImage(image);
                        },
                        onInputImage: (inputImage) async {
                          _canAuthenticate = false;
                          LokasiSekarang = "";
                          cocok = "";
                          setState(() => isMatching = true);
                          _faceFeatures = await extractFaceFeatures(
                              inputImage, _faceDetector);
                          // dapatkanLokasi();
                          setState(() => isMatching = false);

                        }
                    ),
                  ),
                ),
                if (isMatching)
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.only(top: 60),
                      child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            // color: Colors.white,
                            borderRadius: BorderRadius.circular(100.0), // Melengkungkan sudut
                          ),
                          child: Lottie.asset("asset/lottie/scan.json",)),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("Ambil gambar wajah",
                style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 17
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10,bottom: 10, left: 35, right: 35),
              child: ElevatedButton(

                  onPressed: () async {

                    await getId();
                    setState(() => isMatching = true);
                    _fetchUsersAndMatchFace();
                    dapatkanLokasi(context);


                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFFEEEEEE);
                      }
                      return Color(0xFF31363F);
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFF31363F);
                      }
                      return Color(0xFFEEEEEE);
                    }),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color(0xFFEEEEEE), width: 2.0),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Atur nilai ini untuk kelengkungan yang diinginkan
                        side: BorderSide(color: Color(0xFFEEEEEE), width: 2.0), // Menambahkan border
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_outlined, color: Colors.blue, ),
                      SizedBox(width: 20,),
                      Text("Authentikasi wajah dan lokasi", style: TextStyle(),)
                    ],
                  )
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(cocok,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 17
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 32, left: 10, right: 10),
              child: Text("Lokasi Sekarang",
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 17
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
              child: Text(LokasiSekarang,
                textAlign: TextAlign.center,
                softWrap: true,
                style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 17
                ),
              ),
            ),

            Spacer(),
            if (_canAuthenticate && LokasiSekarang != "")
            Padding(
              padding: const EdgeInsets.only(bottom: 50, left: 60, right: 60),
              child: ElevatedButton(
                  onPressed: () async {

                    var url = Uri.http("192.168.1.8:8002","/api/absen");
                    var response = await http.post(url,body: {
                      "user_id" : user_id,
                      'lokasi' : LokasiSekarang,
                      'waktu_masuk' : DateTime.now().toIso8601String()
                    });
                    print(response.body);
                    if(response.statusCode == 200){
                      Map<String, dynamic> responseBody = jsonDecode(response.body);
                      final snackBar = SnackBar(
                        content: Text(responseBody['message']),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFFEEEEEE);
                      }
                      return Color(0xFF31363F);
                    }),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>((states){
                      if(states.contains(MaterialState.pressed)){
                        return Color(0xFF31363F);
                      }
                      return Color(0xFFEEEEEE);
                    }),
                    side: MaterialStateProperty.all<BorderSide>(
                      BorderSide(color: Color(0xFFEEEEEE), width: 2.0),
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Atur nilai ini untuk kelengkungan yang diinginkan
                        side: BorderSide(color: Color(0xFFEEEEEE), width: 2.0), // Menambahkan border
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.co_present_outlined, ),
                      SizedBox(width: 20,),
                      Text("Absen", style: TextStyle(),)
                    ],
                  )
              ),
            ) ,
          ],
        ),
      ),
    );
  }
  Future _setImage(Uint8List imageToAuthenticate) async {
    image2.bitmap = base64Encode(imageToAuthenticate);
    image2.imageType = regula.ImageType.PRINTED;

    // setState(() {
    //   _canAuthenticate = true;
    // });
  }
  double compareFaces(List<FeaturePoint> faceFeatures1, List<FeaturePoint> faceFeatures2) {
    // Mengonversi List<FeaturePoint> menjadi Map<String, Points> untuk akses yang lebih mudah
    var mapFeatures1 = Map.fromIterable(faceFeatures1, key: (item) => item.featureName, value: (item) => item.points);
    var mapFeatures2 = Map.fromIterable(faceFeatures2, key: (item) => item.featureName, value: (item) => item.points);

    // Menghitung jarak Euclidean antara setiap pasangan titik fitur wajah
    double sumRatio = 0.0;
    int numFeatures = 0;

    // List pasangan titik fitur wajah yang akan digunakan dalam perbandingan
    List<List<String>> featurePairs = [
      ['rightEar', 'leftEar'],
      ['rightEye', 'leftEye'],
      ['rightCheek', 'leftCheek'],
      ['rightMouth', 'leftMouth'],
      ['noseBase', 'bottomMouth']
    ];

    // Menghitung rasio jarak Euclidean untuk setiap pasangan titik fitur wajah
    for (var pair in featurePairs) {
      var feature1 = mapFeatures1[pair[0]];
      var feature2 = mapFeatures2[pair[0]];

      // Pastikan kedua titik fitur ada dalam kumpulan fitur
      if (feature1 != null && feature2 != null) {
        double distance1 = euclideanDistance(feature1, mapFeatures1[pair[1]]!);
        double distance2 = euclideanDistance(feature2, mapFeatures2[pair[1]]!);

        // Hitung rasio jarak Euclidean
        double ratio = distance1 / distance2;

        // Tambahkan rasio ke dalam total
        sumRatio += ratio;
        numFeatures++;
      }
    }

    // Menghitung rata-rata rasio dari semua pasangan fitur yang valid
    double averageRatio = numFeatures > 0 ? sumRatio / numFeatures : 0.0;

    return averageRatio;
  }


  double euclideanDistance(Points p1, Points p2) {
    return math.sqrt(math.pow((p1.x! - p2.x!), 2) + math.pow((p1.y! - p2.y!), 2));
  }
  _fetchUsersAndMatchFace() async {
    print("mencoba fetch data API");
    try {
      final response = await http.get(Uri.parse('http://192.168.1.8:8002/api/akun/$user_id'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body); // Ubah ke Map
        print(responseData);

        UserModel user = UserModel.fromJson(responseData); // Karena objek tunggal, tidak perlu looping
        double similarity = compareFaces(_faceFeatures!, user.faceFeatures!);
        if (similarity >= 0.8 && similarity <= 1.5) {
          users.add(user);
        }

        // Lakukan sesuatu dengan users yang cocok
        _matchFaces();
      } else {
        // Tangani respons tidak berhasil
        _showFailureDialog(
          title: "No Users Registered",
          description: "Make sure users are registered first before Authenticating.",
        );
      }
    } catch (e) {
      // Tangani kesalahan saat melakukan permintaan HTTP
      log("Getting User Error: $e");
      setState(() => isMatching = false);
      print("error : $e");
      // CustomSnackBar.errorSnackBar("Something went wrong. Please try again.");
    }
  }
  _matchFaces() async {
    setState(() {
      cocok = "Menganalisa wajah";
    });
    print("match faces dijalankan");
    bool faceMatched = false;
    for (var user in users) {
      image1.bitmap = user.image;
      image1.imageType = regula.ImageType.PRINTED;
      print("mendapatkan image");
      //Face comparing logic.
      var request = regula.MatchFacesRequest();
      request.images = [image1, image2];
      dynamic value = await regula.FaceSDK.matchFaces(jsonEncode(request));

      var response = regula.MatchFacesResponse.fromJson(json.decode(value));
      dynamic str = await regula.FaceSDK.matchFacesSimilarityThresholdSplit(
          jsonEncode(response!.results), 0.75);
      print("Mulai mencocokan wajah");
      var split =
      regula.MatchFacesSimilarityThresholdSplit.fromJson(json.decode(str));
      setState(() {
        _similarity = split!.matchedFaces.isNotEmpty
            ? (split.matchedFaces[0]!.similarity! * 100).toStringAsFixed(2)
            : "error";
        log("similarity: $_similarity");
        print("kecocokan wajah : "+_similarity);
        if (_similarity != "error" && double.parse(_similarity) > 90.00) {
          faceMatched = true;
          loggingUser = user;

        } else {
          faceMatched = false;
        }
      });
      if (faceMatched) {
        print("wajah cocok, bisa absen dengan wajah");
        setState(() => _canAuthenticate = true);
        setState(() {
          cocok = "Wajah cocok\nTingkat kecocokan : $_similarity%";
          trialNumber = 1;
          isMatching = false;

        });
      }
    }
    if (!faceMatched) {
      if (trialNumber == 4) {
        setState(() => trialNumber = 1);
        _showFailureDialog(
          title: "Recognition Failed",
          description: "Face doesn't match. Please try again.",
        );
      } else if (trialNumber == 3) {
        //After 2 trials if the face doesn't match automatically, the registered name prompt
        //will be shown. After entering the name the face registered with the entered name will
        //be fetched and will try to match it with the to be authenticated face.
        //If the faces match, Viola!. Else it means the user is not registered yet.
        // _audioPlayer.stop();
        setState(() {
          isMatching = false;
          trialNumber++;
        });

      } else {
        setState(() => trialNumber++);
        _showFailureDialog(
          title: "Recognition Failed",
          description: "Face doesn't match. Please try again.",
        );
      }
    }
  }
  _showFailureDialog({
    required String title,
    required String description,
  }) {
    setState(() => isMatching = false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {

              },
              child: const Text(
                "Ok",
                style: TextStyle(
                  color: Color(0xFFEEEEEE),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
