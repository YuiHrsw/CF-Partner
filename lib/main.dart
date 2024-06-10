import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStorage().init();
  runApp(
    ChangeNotifierProvider(
        create: (context) => AppStorage(), child: const CFPartner()),
  );
}

class CFPartner extends StatelessWidget {
  const CFPartner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStorage>(
      builder: (BuildContext context, AppStorage value, Widget? child) {
        MaterialColor themeColor = value.getColorTheme();
        var lightTheme = ColorScheme.fromSeed(
            seedColor: themeColor, brightness: Brightness.light);
        var darkTheme = ColorScheme.fromSeed(
            seedColor: themeColor, brightness: Brightness.dark);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CF Partner 2',
          theme: ThemeData(
            fontFamilyFallback: const ['SimHei'],
            colorScheme: lightTheme,
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: lightTheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: TextStyle(
                color: lightTheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamilyFallback: const ['SimHei'],
            colorScheme: darkTheme,
            tooltipTheme: TooltipThemeData(
              decoration: BoxDecoration(
                color: darkTheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: TextStyle(
                color: darkTheme.onSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            useMaterial3: true,
          ),
          themeMode: value.settings.themeMode,
          home: const Home(),
        );
      },
    );
  }
}
