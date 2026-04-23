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

  int get _totalReviews =>
      userData.dailyReviewCounts.values.fold(0, (sum, v) => sum + v);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context, isDark)),
          SliverToBoxAdapter(child: _buildStats(context, isDark)),
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.person,
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                  title: const Text('Аккаунт'),
                  subtitle: Text(
                    userData.userId != null
                        ? 'ID: ${userData.userId}'
                        : 'Локальный режим',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline),
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
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2D1B69), const Color(0xFF1A1A2E)]
              : [Colors.purple.shade600, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                userData.isAuthenticated ? 'Мой профиль' : 'Локальный режим',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Row(
        children: [
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            value: '${userData.studyStreak}',
            label: 'Дней подряд',
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.style_rounded,
            iconColor: Colors.purple,
            value: '${userData.totalCards}',
            label: 'Карточек',
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.layers_rounded,
            iconColor: Colors.blue,
            value: '${userData.decks.length}',
            label: 'Колод',
            isDark: isDark,
          ),
          const SizedBox(width: 10),
          _StatCard(
            icon: Icons.repeat_rounded,
            iconColor: Colors.green,
            value: '$_totalReviews',
            label: 'Повторений',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
