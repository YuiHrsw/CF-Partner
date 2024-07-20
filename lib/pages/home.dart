import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/challenge.dart';
import 'package:cf_partner/pages/exercises.dart';
import 'package:cf_partner/pages/tracker.dart';
import 'package:cf_partner/pages/settings.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int currentPageIndex = 0;
  final exercise = GlobalKey<NavigatorState>();
  final tracker = GlobalKey<NavigatorState>();
  final challenge = GlobalKey<NavigatorState>();
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
          labelType: NavigationRailLabelType.all,
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
              icon: Icon(Icons.text_snippet),
              label: Text('Exercises'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.track_changes),
              label: Text('Tracker'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.task_alt),
              label: Text('Challenge'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.filter_vintage),
              label: Text('Settings'),
            ),
          ],
        ),
        Expanded(
          child: IndexedStack(
            index: currentPageIndex,
            children: [
              Navigator(
                key: exercise,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Exercises(),
                ),
              ),
              Navigator(
                key: tracker,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const TrackerPage(),
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
