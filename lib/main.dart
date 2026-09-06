import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/feed_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/map_screen.dart';
import 'screens/snap_camera_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseMapApp());
}

class PulseMapApp extends StatelessWidget {
  const PulseMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'PulseMap: CrowdSnap Varanasi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D0F17),
          primaryColor: const Color(0xFFFFD600),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD600),
            secondary: Color(0xFF00E676),
            surface: Color(0xFF131722),
          ),
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MapScreen(),
    FeedScreen(),
    LeaderboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0D0F17),
          border: Border(
            top: BorderSide(color: Colors.white12, width: 0.5),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            if (index == 2) {
              // Direct Snap action
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SnapCameraScreen()),
              );
            } else if (index > 2) {
              setState(() {
                _selectedIndex = index - 1;
              });
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          backgroundColor: const Color(0xFF0D0F17),
          indicatorColor: const Color(0xFFFFD600).withValues(alpha: 0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.map_rounded, color: Colors.white60),
              selectedIcon: Icon(Icons.map_rounded, color: Color(0xFFFFD600)),
              label: 'Heatmap',
            ),
            NavigationDestination(
              icon: Icon(Icons.dynamic_feed_rounded, color: Colors.white60),
              selectedIcon: Icon(Icons.dynamic_feed_rounded, color: Color(0xFFFFD600)),
              label: 'Pulse Feed',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded, color: Color(0xFFFFD600), size: 28),
              selectedIcon: Icon(Icons.add_circle_rounded, color: Color(0xFFFFD600), size: 28),
              label: 'Post Snap',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_rounded, color: Colors.white60),
              selectedIcon: Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD600)),
              label: 'Scouts & Ranks',
            ),
          ],
        ),
      ),
    );
  }
}
