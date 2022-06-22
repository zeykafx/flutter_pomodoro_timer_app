import 'package:flutter/material.dart';
import 'package:flutter_pomodoro_timer_app/Pages/Pomo/pomo.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Pages/Pomo/pomo_page.dart';
import 'Pages/Settings/settings_page.dart';

main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

const List<Color> colorOptions = [
  Color.fromRGBO(44, 62, 80, 1.0),
  Colors.teal,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.pink,
  Colors.purple,
  Colors.red,
];

const List<String> colorText = <String>[
  "Default Blue",
  "Teal",
  "Green",
  "Yellow",
  "Orange",
  "Pink",
  "Purple",
  "Red",
];


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
    darkModeEnabled = box.read("DarkMode") ?? true;
    if (!darkModeEnabled) {
      Get.changeThemeMode(ThemeMode.dark);
    }
    colorSelected = box.read("colorSelected") ?? 0;
    super.initState();
  }

  void changeDarModeEnabled(bool newVal) {
    setState(() {
      darkModeEnabled = newVal;
      box.write("DarkMode", newVal);
    });
  }

  int colorSelected = 0;

  void changeColorSelected(int colorIndex) {
    setState(() {
      colorSelected = colorIndex;
      box.write("colorSelected", colorSelected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pomo Focus',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colorOptions[colorSelected],
        brightness: Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colorOptions[colorSelected],
        brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: ThemeMode.light,
      home: SafeArea(top: true, child: Main(
          title: 'Pomo Focus',
          darkModeEnabled: darkModeEnabled,
          changeDarModeEnabled: changeDarModeEnabled,
          changeColorSelected: changeColorSelected,
          colorSelected: colorSelected,
      )),
    );
  }
}

class Main extends StatefulWidget {
  const Main({Key? key,
    required this.title,
    required this.darkModeEnabled,
    required this.changeDarModeEnabled,
    required this.changeColorSelected,
    required this.colorSelected
  }) : super(key: key);

  final String title;
  final bool darkModeEnabled;
  final Function changeDarModeEnabled;
  final Function(int) changeColorSelected;
  final int colorSelected;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget createScreen(int index) {
    switch(index) {
      case 0:
        return const PomoPage();
      case 1:
        return const SettingsPage();
      default:
        return const PomoPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          // hoverColor: Colors.transparent
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.timer),
              label: 'Pomodoro',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
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
                    widget.changeDarModeEnabled(Get.isDarkMode);
                  });
                },
                icon: widget.darkModeEnabled ? const Icon(Icons.dark_mode, color: Colors.black, size: 18) : const Icon(Icons.sunny, color: Colors.white, size: 18)),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            itemBuilder: (context) {
              return List.generate(colorOptions.length, (index) {
                return PopupMenuItem(
                    value: index,
                    child: Wrap(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            index == widget.colorSelected
                                ? Icons.color_lens
                                : Icons.color_lens_outlined,
                            color: colorOptions[index],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Text(colorText[index]))
                      ],
                    ));
              });
            },
            onSelected: widget.changeColorSelected,
          )
        ],
      ),
      body: createScreen(_selectedIndex),
    );
  }
}
