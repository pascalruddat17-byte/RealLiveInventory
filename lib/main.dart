import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/inventory_controller.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/room/room_screen.dart';
import 'features/scan/scan_screen.dart';
import 'features/search/search_screen.dart';
import 'repositories/json_inventory_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RealLifeInventoryApp());
}

class RealLifeInventoryApp extends StatefulWidget {
  const RealLifeInventoryApp({super.key});

  @override
  State<RealLifeInventoryApp> createState() => _RealLifeInventoryAppState();
}

class _RealLifeInventoryAppState extends State<RealLifeInventoryApp> {
  late final InventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = InventoryController(repository: JsonInventoryRepository());
    controller.initialize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RealLife Inventory',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: InventoryShell(controller: controller),
    );
  }
}

class InventoryShell extends StatefulWidget {
  const InventoryShell({super.key, required this.controller});

  final InventoryController controller;

  @override
  State<InventoryShell> createState() => _InventoryShellState();
}

class _InventoryShellState extends State<InventoryShell> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final screens = [
          HomeScreen(
            controller: controller,
            onOpenScan: () => _select(2),
            onOpenSearch: () => _select(1),
            onOpenRoom: () => _select(3),
            onOpenHistory: () => _select(4),
          ),
          SearchScreen(
            controller: controller,
            onOpenRoom: () => _select(3),
          ),
          ScanScreen(controller: controller),
          RoomScreen(controller: controller),
          HistoryScreen(controller: controller),
        ];

        return Scaffold(
          appBar: AppBar(
            title: const Text('RealLife Inventory'),
            actions: [
              IconButton(
                tooltip: 'Suche',
                onPressed: () => _select(1),
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          body: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    if (controller.errorMessage != null)
                      MaterialBanner(
                        content: Text(controller.errorMessage!),
                        actions: [
                          TextButton(
                            onPressed: controller.clearError,
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: KeyedSubtree(
                          key: ValueKey(selectedIndex),
                          child: screens[selectedIndex],
                        ),
                      ),
                    ),
                  ],
                ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: _select,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Start',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Suche',
              ),
              NavigationDestination(
                icon: Icon(Icons.center_focus_strong),
                label: 'Scan',
              ),
              NavigationDestination(
                icon: Icon(Icons.view_in_ar_outlined),
                label: 'Zimmer',
              ),
              NavigationDestination(
                icon: Icon(Icons.archive_outlined),
                label: 'Historie',
              ),
            ],
          ),
        );
      },
    );
  }

  void _select(int index) {
    setState(() => selectedIndex = index);
  }
}
