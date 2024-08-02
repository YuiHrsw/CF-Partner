import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/challenge.dart';
import 'package:cf_partner/pages/codespace.dart';
import 'package:cf_partner/pages/exercises.dart';
import 'package:cf_partner/pages/toolbox.dart';
import 'package:cf_partner/pages/settings.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int currentPageIndex = 1;
  final exercise = GlobalKey<NavigatorState>();
  final tracker = GlobalKey<NavigatorState>();
  final challenge = GlobalKey<NavigatorState>();
  final toolbox = GlobalKey<NavigatorState>();
  final settings = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        NavigationRail(
          selectedIndex: currentPageIndex,
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          // indicatorShape: const CircleBorder(),

          minWidth: 70,
          // labelType: NavigationRailLabelType.all,
          labelType: NavigationRailLabelType.none,
          trailing: Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Change theme mode',
                    hoverColor: colorScheme.primaryContainer,
                    iconSize: 28,
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? const Icon(Icons.wb_sunny)
                        : const Icon(Icons.dark_mode),
                    onPressed: () {
                      setState(() {
                        AppStorage().settings.themeMode =
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.light
                                : ThemeMode.dark;
                      });
                      AppStorage().saveSettings();
                      AppStorage().updateStatus();
                    },
                  ),
                  const SizedBox(
                    height: 4,
                  )
                ],
              ),
            ),
          ),
          destinations: const <NavigationRailDestination>[
            NavigationRailDestination(
              padding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.feed,
                size: 28,
              ),
              label: Text('Codespace'),
            ),
            NavigationRailDestination(
              padding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.category,
                size: 28,
              ),
              label: Text('Categories'),
            ),
            NavigationRailDestination(
              padding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.calendar_month_rounded,
                size: 28,
              ),
              label: Text('Challenge'),
            ),
            NavigationRailDestination(
              padding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.token_rounded,
                size: 28,
              ),
              label: Text('Toolbox'),
            ),
            NavigationRailDestination(
              padding: EdgeInsets.symmetric(vertical: 4),
              icon: Icon(
                Icons.filter_vintage,
                size: 28,
              ),
              label: Text('Settings'),
            ),
          ],
        ),
        Expanded(
          child: IndexedStack(
            index: currentPageIndex,
            children: [
              Navigator(
                key: tracker,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Codespace(),
                ),
              ),
              Navigator(
                key: exercise,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Exercises(),
                ),
              ),
              Navigator(
                key: challenge,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Challenge(),
                ),
              ),
              Navigator(
                key: toolbox,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Toolbox(),
                ),
              ),
              Navigator(
                key: settings,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Settings(),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
