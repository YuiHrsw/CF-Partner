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
        MaterialColor themeColor = value.settings.getColorTheme();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CF Partner',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: themeColor, brightness: Brightness.light),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
                seedColor: themeColor, brightness: Brightness.dark),
            useMaterial3: true,
          ),
          themeMode: value.settings.themeMode,
          home: const Home(),
        );
      },
    );
  }
}
