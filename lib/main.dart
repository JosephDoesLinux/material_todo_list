import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart'; // Import the new package
import 'home.dart'; // Assuming your home screen is here

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Use DynamicColorBuilder to get the system's color schemes
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        
        // 2. Define a base color to use as a fallback if dynamic colors aren't available (e.g., on a non-Pixel Android device or older OS)
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        const Color defaultSeedColor = Colors.blue; // Use a default color for the fallback

        if (lightDynamic != null && darkDynamic != null) {
          // If dynamic colors are available, use them directly
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized(); // harmonized makes sure all colors work well together
        } else {
          // If not available, generate a scheme based on our default seed color
          lightColorScheme = ColorScheme.fromSeed(seedColor: defaultSeedColor);
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: defaultSeedColor,
            brightness: Brightness.dark,
          );
        }

        // 3. Return the MaterialApp, applying the dynamic (or fallback) theme data
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Material To-Do List',
          
          // Light Theme: uses the dynamic or fallback light scheme
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          
          // Dark Theme: uses the dynamic or fallback dark scheme
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          
          // Your app will automatically switch between light/dark themes if the user changes their system setting
          themeMode: ThemeMode.system,

          home: const Home(),
        );
      }
    );
  }
}