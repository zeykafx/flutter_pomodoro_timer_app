import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Pages/Pomo/pomo_page.dart';
import 'Pages/Settings/settings_page.dart';

main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(
      milliseconds:
          300)); // HACK: fix for https://github.com/flutter/flutter/issues/101007
  runApp(const MyApp());

  if ([TargetPlatform.windows, TargetPlatform.linux, TargetPlatform.macOS]
      .contains(defaultTargetPlatform)) {
    doWhenWindowReady(() {
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

    initNotifs();

    super.initState();
  }

  Future<void> initNotifs() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  void selectNotification(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
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
      home: Column(
        children: [
          if ([
            TargetPlatform.windows,
            TargetPlatform.linux,
            TargetPlatform.macOS
          ].contains(defaultTargetPlatform))
            WindowTitleBarBox(
              child: Container(
                color: darkModeEnabled ? Colors.white : Colors.black,
                child: Row(children: [
                  Expanded(
                      child: MoveWindow(
                          child: Center(
                              child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 12,
                          color: darkModeEnabled ? Colors.black : Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                        child: const Text(
                          'Pomo Focus',
                        ),
                      ),
                    ),
                  )))),
                  WindowButtons(
                    isDarkMode: darkModeEnabled,
                  ),
                ]),
              ),
            ),
          Expanded(
            child: Main(
              title: 'Pomo Focus',
              darkModeEnabled: darkModeEnabled,
              changeDarModeEnabled: changeDarModeEnabled,
              changeColorSelected: changeColorSelected,
              colorSelected: colorSelected,
            ),
          )
        ],
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  final bool isDarkMode;

  const WindowButtons({Key? key, required this.isDarkMode}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: isDarkMode ? Colors.black : Colors.white,
            iconMouseDown: isDarkMode ? Colors.black : Colors.white,
            iconMouseOver: isDarkMode ? Colors.black : Colors.white,
            mouseOver: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            mouseDown: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        MaximizeWindowButton(
          colors: WindowButtonColors(
            iconNormal: isDarkMode ? Colors.black : Colors.white,
            iconMouseDown: isDarkMode ? Colors.black : Colors.white,
            iconMouseOver: isDarkMode ? Colors.black : Colors.white,
            mouseOver: isDarkMode
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.1),
            mouseDown: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        CloseWindowButton(
          colors: WindowButtonColors(
            iconNormal: isDarkMode ? Colors.black : Colors.white,
            mouseOver: Colors.redAccent,
            mouseDown: Colors.red,
          ),
        ),
      ],
    );
  }
}

class Main extends StatefulWidget {
  const Main(
      {Key? key,
      required this.title,
      required this.darkModeEnabled,
      required this.changeDarModeEnabled,
      required this.changeColorSelected,
      required this.colorSelected})
      : super(key: key);

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
  bool pageChanged = false;

  late PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    setState(() {
      pageChanged = false;
    });
    pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      pageChanged = true;
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  // Widget createScreen(int index) {
  //   switch (index) {
  //     case 0:
  //       return PomoPage(pageChanged: pageChanged);
  //     case 1:
  //       return const SettingsPage();
  //     default:
  //       return PomoPage(pageChanged: pageChanged);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
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
                    Get.changeThemeMode(
                        Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                    widget.changeDarModeEnabled(Get.isDarkMode);
                  });
                },
                icon: widget.darkModeEnabled
                    ? const Icon(Icons.dark_mode, color: Colors.black, size: 18)
                    : const Icon(Icons.sunny, color: Colors.white, size: 18)),
          ),
          PopupMenuButton(
            tooltip: "Show color menu",
            icon: const Icon(Icons.color_lens),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    width: 0.3)),
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
      body: SizedBox.expand(
          child: PageView(
        controller: pageController,
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [PomoPage(pageChanged: pageChanged), const SettingsPage()],
      )),
    );
  }
}
