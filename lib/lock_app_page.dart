

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'authenticate_face/home_page.dart';
class LockAppPage extends StatefulWidget {
  const LockAppPage({super.key});

  @override
  State<LockAppPage> createState() => _LockAppPageState();
}

class _LockAppPageState extends State<LockAppPage> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = "Not Recognized";
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
      super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();
    _authenticate();
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
  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try{
      availableBiometrics = await auth.getAvailableBiometrics();
    }on Exception catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if(!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to authenticate'
      );
    } catch (e) {
      print("error : $e");
    }

    if (authenticated) {
      // Autentikasi berhasil, lanjut ke halaman berikutnya atau lakukan aksi lain
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Autentikasi gagal, mungkin karena pengguna tidak memasukkan fingerprintnya dengan benar
      // Tampilkan pesan kesalahan kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fingerprint authentication failed'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.maxFinite,
        height: double.maxFinite,
        color: Color(0xFF222831),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text("Scan your fingerprint",style: TextStyle(color: Colors.white),),
            ),
            Builder(
              builder: (context) {
                return ElevatedButton(onPressed: (){
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage())
                  );
                }, child: Text("bypass"));
              }
            ),
            Text('Can check biometrics: $_canCheckBiometrics',style: TextStyle(color: Colors.white),),
            Text('Available biometrics: $_availableBiometrics',style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
