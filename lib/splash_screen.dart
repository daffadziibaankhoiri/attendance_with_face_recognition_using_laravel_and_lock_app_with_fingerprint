import 'package:attendance_with_laravel/authenticate_face/home_page.dart';
import 'package:attendance_with_laravel/lock_app_page.dart';
import 'package:attendance_with_laravel/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = "Not Recognized";
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  @override
  void initState() {
    super.initState();
    getSetting();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    );

    _animationController!.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {

      Future.delayed(Duration(seconds: 3), () {
        checkLoginStatus();
      });
    });
  }
  bool lock_app = false;
  void getSetting() async {
    final simpanan = await SharedPreferences.getInstance();
    bool? lock = simpanan.getBool('Lock');
    lock_app = lock!;
  }
  void checkLoginStatus() async {

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    print(token);
    if (token != null && token.isNotEmpty) {
      // Jika token ada dan tidak kosong, arahkan ke HomePage

      if(lock_app == true){
        _authenticate();
        // Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => LockAppPage())
        // );
      }else{
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage())
        );
      }

    } else {
      // Jika token tidak ada atau kosong, arahkan ke LoginPage
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login_Page())
      );
    }
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
          localizedReason: 'Scan your fingerprint to open app'
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
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Color(0xFF222831),
          child: Center(
            child: FadeTransition(
              opacity: _animation!,
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Text(
                  "Absensi dengan Pengenalan wajah dan lokasi",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFEEEEEE),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
