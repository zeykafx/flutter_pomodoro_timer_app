import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Pages/Pomo/pomo.dart';

main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GetStorage box = GetStorage();
  bool darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    darkModeEnabled = box.read("DarkMode") ?? false;
    if (darkModeEnabled) {
      Get.changeTheme(ThemeData.dark());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomo Focus',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromRGBO(44, 62, 80, 1.0),
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color.fromRGBO(44, 62, 80, 1.0),
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.light,
      home: SafeArea(top: true, child: Main(title: 'Pomo Focus', darkModeEnabled: darkModeEnabled,)),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key, required this.title, required this.darkModeEnabled}) : super(key: key);

  final String title;
  final bool darkModeEnabled;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: "Toggle dark theme",
            waitDuration: const Duration(milliseconds: 500),
            child: IconButton(
                onPressed: () {
                  setState(() {
                    Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                  });
                },
                icon: widget.darkModeEnabled ? const Icon(Icons.sunny, color: Colors.white, size: 18) : const Icon(Icons.dark_mode, color: Colors.black, size: 18)),
          )
        ],
      ),
      body: const RepaintBoundary(child: Pomo()),
    );
  }
}
