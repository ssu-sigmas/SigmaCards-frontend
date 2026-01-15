import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/deck.dart';
import 'home_screen.dart';
import 'decks_tab_screen.dart';
import 'profile_screen.dart';

/// Корневая оболочка после входа: нижняя навигация + вкладки.
class MainShellScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onCreateDeck;
  final Function(Deck) onEditDeck;
  final Function(Deck) onStudyDeck;
  final VoidCallback onQuickStudy;
  final Function(String) onDeleteDeck;
  final VoidCallback onAIImport;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const MainShellScreen({
    super.key,
    required this.userData,
    required this.onCreateDeck,
    required this.onEditDeck,
    required this.onStudyDeck,
    required this.onQuickStudy,
    required this.onDeleteDeck,
    required this.onAIImport,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  void _openDecksTab() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(
            userData: widget.userData,
            onCreateDeck: widget.onCreateDeck,
            onEditDeck: widget.onEditDeck,
            onStudyDeck: widget.onStudyDeck,
            onQuickStudy: widget.onQuickStudy,
            onDeleteDeck: widget.onDeleteDeck,
            onAIImport: widget.onAIImport,
            onOpenDecksTab: _openDecksTab,
          ),
          DecksTabScreen(
            userData: widget.userData,
            onCreateDeck: widget.onCreateDeck,
            onEditDeck: widget.onEditDeck,
            onStudyDeck: widget.onStudyDeck,
            onDeleteDeck: widget.onDeleteDeck,
          ),
          ProfileScreen(
            userData: widget.userData,
            onToggleTheme: widget.onToggleTheme,
            onLogout: widget.onLogout,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Главная',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books_rounded),
            label: 'Колоды',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
