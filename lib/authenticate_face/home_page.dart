
import 'package:attendance_with_laravel/authenticate_face/attendance_page.dart';
import 'package:attendance_with_laravel/login_page.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
  getSetting();
  _checkBiometrics();
    super.initState();
  }
  bool? isToggled;
  void clearToken() async {
    final simpanan = await SharedPreferences.getInstance();
    var token = simpanan.remove('token');
    print("token terhapus :  $token");
  }
  void setSetting() async {
    final simpanan = await SharedPreferences.getInstance();
    simpanan.setBool('Lock',isToggled!);
    bool? lock = simpanan.getBool('Lock');
    print("lock app = $lock");
  }
  void getSetting() async {
    final simpanan = await SharedPreferences.getInstance();
    bool? lock = simpanan.getBool('Lock');
    setState(() {
      isToggled = lock ?? false;
    });

  }
  Future<void> _checkBiometrics() async {
    bool canCheckiometrics;
    try{
      canCheckiometrics = await auth.canCheckBiometrics;
    } on Exception catch (e){
      canCheckiometrics = false;
      print(e);
    }

    if(!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckiometrics;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Color(0xFF222831),
        child: Column (
          children: [
            Row(
              children: [
                Builder(
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 35,left: 20),
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
                          onPressed: () async {
                            clearToken();
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Login_Page())
                            );


                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 15
                              ),
                            ),
                          ),

                        ),
                      );
                    }
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top:5,left: 20, right: 20),
              child: Text("Home"
                ,style: TextStyle(
                  color: Color(0xFFEEEEEE),
                  fontWeight: FontWeight.bold,
                  fontSize: 30,

                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF31363F),
                  borderRadius: BorderRadius.circular(15.0), // Melengkungkan sudut
                  border: Border.all(
                    color: Color(0xFFEEEEEE), // Warna border
                    width: 2.0, // Ketebalan border
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(

                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF76ABAE),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(CupertinoIcons.time, color: Color(0xFFEEEEEE), weight: 20, size: 30),
                      ),
                    ),
                    Spacer(),
                    Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 20),
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
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => AttendancePage())
                                );


                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Absen",
                                  style: TextStyle(
                                      fontSize: 15
                                  ),
                                ),
                              ),

                            ),
                          );
                        }
                    ),
                    SizedBox(
                      width: 20,
                    )
                  ],
                ),
              ),
            ),
            if(_canCheckBiometrics)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 300,
                height: 100,
                decoration: BoxDecoration(
                  color: Color(0xFF31363F),
                  borderRadius: BorderRadius.circular(15.0), // Melengkungkan sudut
                  border: Border.all(
                    color: Color(0xFFEEEEEE), // Warna border
                    width: 2.0, // Ketebalan border
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(

                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFF76ABAE),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Icon(Icons.fingerprint, color: Color(0xFFEEEEEE), weight: 20,size: 30,),
                      ),
                    ),
                    SizedBox(width: 20,),
                    Text("Fingerprint Lock",
                      style: TextStyle(
                        color: Color(0xFF76ABAE),
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),

                    ),
                    Spacer(),
                    Switch(
                        value: isToggled!,
                        onChanged: (value){
                        setState(() {
                          isToggled = value;
                          setSetting();
                        });
                      },

                      activeColor:Color(0xFFEEEEEE), // Warna thumb saat switch ON
                      activeTrackColor: Color(0xFF76ABAE), // Warna track saat switch ON
                      inactiveThumbColor:Color(0xFFEEEEEE),  // Warna thumb saat switch OFF
                      inactiveTrackColor: Color(0xFF31363F), // Warna track saat switch OFF
                    ),
                    SizedBox(
                      width: 20,
                    )
                  ],
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }

}


