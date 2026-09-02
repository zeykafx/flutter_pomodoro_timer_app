import 'dart:io';

import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Pages/Pomo/pomo_page.dart';
import 'Pages/Settings/settings_page.dart';

void main() async {
  Animate.restartOnHotReload = true;

  WidgetsFlutterBinding.ensureInitialized();

  // prevent landscape mode
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const MyApp());
}

const List<Color> colorOptions = [
  Colors.blue,
  Colors.lightBlueAccent,
  Colors.teal,
  Colors.lime,
  Colors.greenAccent,
  Colors.green,
  Colors.yellow,
  Colors.orange,
  Colors.deepOrange,
  Colors.pink,
  Colors.purple,
  Colors.purpleAccent,
  Colors.red,
];

const List<String> colorText = <String>[
  "Blue",
  "Light Blue",
  "Teal",
  "Lime",
  "Light Green",
  "Green",
  "Yellow",
  "Orange",
  "Deep Orange",
  "Pink",
  "Purple",
  "Light Purple",
  "Red",
];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkModeEnabled = false;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    initPrefsState();
    initNotifs();

    super.initState();
  }

  Future<void> initPrefsState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    darkModeEnabled = prefs.getBool("DarkMode") ?? true;
    _themeMode = darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
    colorSelected = prefs.getInt("colorSelected") ?? 0;
    hasChangedColor = prefs.getBool("hasChangedColor") ?? false;
    hasChangedDarkTheme = prefs.getBool("hasChangedDarkTheme") ?? false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> initNotifs() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings("icon");
    const DarwinInitializationSettings initializationSettingsMacOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  void toggleThemeMode() {
    final bool makeDark = _themeMode != ThemeMode.dark;
    setState(() {
      _themeMode = makeDark ? ThemeMode.dark : ThemeMode.light;
      darkModeEnabled = makeDark;
    });
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("DarkMode", makeDark);
    });
  }

  int colorSelected = 0;
  bool hasChangedColor = false;
  bool hasChangedDarkTheme = false;

  Future<void> changeColorSelected(int colorIndex) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      colorSelected = colorIndex;
      prefs.setInt("colorSelected", colorSelected);
      prefs.setBool("hasChangedColor", hasChangedColor);
      prefs.setBool("hasChangedDarkTheme", hasChangedDarkTheme);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size mediaQuerySize = MediaQuery.of(context).size;
    if (mediaQuerySize.width > 500) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    return MaterialApp(
      title: 'Pomo Focus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colorOptions[colorSelected],
        brightness: Brightness.light,
        // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: colorOptions[colorSelected],
        brightness: Brightness.dark,
        // textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: _themeMode,
      home: Column(
        children: [
          Expanded(
            child: Main(
              title: 'Pomo Focus',
              darkModeEnabled: darkModeEnabled,
              toggleThemeMode: toggleThemeMode,
              changeColorSelected: changeColorSelected,
              colorSelected: colorSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class Main extends StatefulWidget {
  const Main({
    super.key,
    required this.title,
    required this.darkModeEnabled,
    required this.toggleThemeMode,
    required this.changeColorSelected,
    required this.colorSelected,
  });

  final String title;
  final bool darkModeEnabled;
  final void Function() toggleThemeMode;
  final Function(int) changeColorSelected;
  final int colorSelected;

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  int _selectedIndex = 0;
  bool pageChanged = false;

  late PageController pageController = PageController();

  bool battDialogOpen = false;

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
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
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

  Future<void> checkBattOpti() async {
    if (Platform.isAndroid) {
      bool? isBatteryOptimizationDisabled = await DisableBatteryOptimization.isBatteryOptimizationDisabled ?? false;

      if (!isBatteryOptimizationDisabled && !battDialogOpen) {
        setState(() {
          battDialogOpen = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Disable Battery Optimization?'),
              content: Text('Battery Optimization must be disabled for the app to be able to run in the background, press OK to go to the related settings'),
              actions: <Widget>[
                TextButton(
                  child: Text('Not Now'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Dismiss alert dialog
                    setState(() {
                      battDialogOpen = false;
                    });
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () async {
                    Navigator.of(context).pop();

                    await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();

                    setState(() {
                      battDialogOpen = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    checkBattOpti();

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer), label: 'Pomodoro'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Tooltip(
            message: "Toggle dark theme",
            waitDuration: const Duration(milliseconds: 500),
            child: IconButton(
              onPressed: () {
                widget.toggleThemeMode();
              },
              icon: widget.darkModeEnabled ? const Icon(Icons.dark_mode, size: 18) : const Icon(Icons.sunny, size: 18),
            ),
          ),
          PopupMenuButton(
            tooltip: "Show color menu",
            icon: const Icon(Icons.color_lens),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Theme.of(context).colorScheme.secondaryContainer, width: 0.3),
            ),
            itemBuilder: (context) {
              return List.generate(colorOptions.length, (index) {
                return PopupMenuItem(
                  value: index,
                  child: Wrap(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Icon(index == widget.colorSelected ? Icons.color_lens : Icons.color_lens_outlined, color: colorOptions[index]),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 20), child: Text(colorText[index])),
                    ],
                  ),
                );
              });
            },
            onSelected: widget.changeColorSelected,
          ),
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
          children: [
            PomoPage(pageChanged: pageChanged),
            const SettingsPage(),
          ],
        ),
      ),
    );
  }
}
