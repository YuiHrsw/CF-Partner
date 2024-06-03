import 'package:cf_partner/backend/storage.dart';
import 'package:cf_partner/pages/exercises.dart';
import 'package:cf_partner/pages/contests.dart';
import 'package:cf_partner/pages/settings.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int currentPageIndex = 0;
  final questionList = GlobalKey<NavigatorState>();
  final explore = GlobalKey<NavigatorState>();
  final settings = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    late final backgroundColor = Color.alphaBlend(
        colorScheme.primary.withOpacity(0.04), colorScheme.surface);
    return Row(
      children: <Widget>[
        NavigationRail(
          backgroundColor: backgroundColor,
          indicatorColor: colorScheme.primaryContainer,
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
                    hoverColor: colorScheme.primaryContainer,
                    iconSize: 28,
                    icon: Theme.of(context).brightness == Brightness.dark
                        ? const Icon(Icons.wb_sunny)
                        : const Icon(Icons.mode_night),
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
              icon: Icon(Icons.sticky_note_2),
              label: Text('Exercises'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.emoji_events),
              label: Text('Contests'),
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
                key: questionList,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const Exercises(),
                ),
              ),
              Navigator(
                key: explore,
                onGenerateRoute: (route) => MaterialPageRoute(
                  settings: route,
                  builder: (context) => const ExplorePage(),
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
