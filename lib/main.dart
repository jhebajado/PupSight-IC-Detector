import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/data/storage.dart';
import 'package:ic_scanner/screens/register.dart';

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
          elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.white),
            backgroundColor: MaterialStatePropertyAll(themePurple),
          )),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            filled: true,
            fillColor: const Color(0xff0f0f0f),
          )),
      debugShowCheckedModeBanner: false,
      home: const RegisterScreen(),
    );
  }
}
