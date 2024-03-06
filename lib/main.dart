import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/data/storage.dart';
import 'package:ic_scanner/screens/home.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    const themePurple = Color(0xff9146FF);
    const themeRed = Color(0xffe84037);
    const themePurpleLight = Color(0xffDAC1FF);
    const themeBlack = Color(0xff0E0E10);

    Storage.loadData();

    return MaterialApp(
      title: 'IC Scanner',
      theme: ThemeData(
        primaryColor: themePurple,
        scaffoldBackgroundColor: themeBlack,
        colorScheme: const ColorScheme.dark(
            primary: themePurple, secondary: Colors.white, error: themeRed),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          backgroundColor: themePurple,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          shape: CircleBorder(),
          backgroundColor: themePurple,
        ),
        tabBarTheme: const TabBarTheme(
          unselectedLabelColor: themePurpleLight,
          labelColor: Colors.white,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white, width: 2.0),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
