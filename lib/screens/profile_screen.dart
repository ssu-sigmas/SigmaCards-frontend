import 'package:flutter/material.dart';
import '../models/user_data.dart';

class ProfileScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userData,
    required this.onToggleTheme,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            title: const Text('Аккаунт'),
            subtitle: Text(
              userData.userId != null ? 'ID: ${userData.userId}' : 'Локальный режим',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
            ),
          ),
          const Divider(),
          SwitchListTile(
            secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            title: const Text('Тёмная тема'),
            value: isDark,
            onChanged: (_) => onToggleTheme(),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Выйти'),
            onTap: onLogout,
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'SigmaCards — карточки и интервальные повторения.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
