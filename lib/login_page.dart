import 'dart:convert';

import 'package:attendance_with_laravel/authenticate_face/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import 'package:http/http.dart' as http;
class Login_Page extends StatefulWidget {
  const Login_Page({super.key});

  @override
  State<Login_Page> createState() => _Login_PageState();
}

class _Login_PageState extends State<Login_Page> {
  bool show = true;
  String loginuser = "";
  String loginpassword = "";
  String url_api =  "192.168.1.8:8000";
  String Token = "";
  String user_id = "";
  FocusNode _passwordFocus = FocusNode();
  FocusNode _usernameFocus = FocusNode();
  final TextEditingController loginuserController = TextEditingController();
  final TextEditingController loginpassController = TextEditingController();
  void setPrefs() async {
    final simpanan = await SharedPreferences.getInstance();
    print("setPrefs dijalankan");
    await  simpanan.setString('token', Token);
    await  simpanan.setString('user_id', user_id);
    String? tesShared = simpanan.getString('token');
    String? idUser = simpanan.getString('user_id');
    print('isi id $idUser');
    print("isi token $tesShared");
  }
  @override
  Widget build(BuildContext context) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            color: Color(0xFF222831),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: ClipOval(
                            child: Container(
                                height: 160,
                                width: 160,
                                // decoration: BoxDecoration(
                                //   shape: BoxShape.circle,
                                //
                                // ),
                                child: Lottie.asset('asset/lottie/login.json')
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10,left: 20, right: 20),
                        child: Text("Login"
                         ,style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,

                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15,left: 50, right: 50),
                        child: TextField(
                          controller: loginuserController,
                          onChanged: (username){
                            setState(() {
                              loginuser = username;
                            });
                          },
                          style: const TextStyle(
                              color: Color(0xFFEEEEEE)
                          ),
                          focusNode: _usernameFocus,
                          cursorColor: Color(0xFF76ABAE),
                          autofocus: false,
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
                          controller: loginpassController,
                          onChanged: (password){
                            setState(() {
                              loginpassword = password;
                            });
                          },
                          style: const TextStyle(
                              color: Color(0xFFEEEEEE)
                          ),
                          focusNode: _passwordFocus,
                          obscureText: show,
                          autofocus: false,
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
                      Builder(
                        builder: (context) {
                          return Padding(
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
                                  _passwordFocus.unfocus();
                                  _usernameFocus.unfocus();
                                  var url = Uri.http("192.168.1.8:8002","/api/login");
                                  var response = await http.post(url, body: {
                                    "nama" : loginuser.toString(),
                                    "password" : loginpassword.toString()
                                  });
                                  print(response.body);
                                  if(response.statusCode == 200){
                                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                                    user_id = responseBody['id'].toString();
                                    Token = responseBody['token'];
                                    setPrefs();
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomePage())
                                    );
                                  }
                                  else if(response.statusCode == 404){
                                    Map<String, dynamic> responseBody = jsonDecode(response.body);
                                    final snackBar = SnackBar(
                                        content: Text(responseBody['message']),
                                      duration: Duration(seconds: 3),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                   "Masuk",
                                   style: TextStyle(
                                      fontSize: 20
                                   ),
                                  ),
                                ),

                            ),
                          );
                        }
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 15,
                  child: Builder(
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom,
                        ),
                        child: InkWell(
                          onTap: (){
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RegisterPage())
                            );
                          },
                          child: Text(
                            "Belum punya akun? Daftar Disini",
                            style: TextStyle(
                              color: Color(0xFF76ABAE),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
