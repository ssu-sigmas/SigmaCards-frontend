import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../widgets/stat_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class HeaderSection extends StatelessWidget {
  final UserData userData;
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HeaderSection({
    super.key,
    required this.userData,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? AppColors.headerGradientDark
              : AppColors.headerGradientLight,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppStyles.headerBorderRadius),
          bottomRight: Radius.circular(AppStyles.headerBorderRadius),
        ),
      ),
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: AppStyles.defaultPadding),
          _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SigmaCards', style: AppStyles.headerTitle),
            const SizedBox(height: 4),
            Text('Keep learning every day', style: AppStyles.headerSubtitle),
          ],
        ),
        IconButton(
          onPressed: onToggleTheme,
          icon: Icon(
            isDark ? Icons.wb_sunny : Icons.dark_mode,
            color: Colors.white,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department,
            iconColor: AppColors.streakIconColor,
            value: '${userData.studyStreak}',
            label: 'Day Streak',
          ),
        ),
        const SizedBox(width: AppStyles.sectionSpacing),
        Expanded(
          child: StatCard(
            icon: Icons.calendar_today,
            iconColor: AppColors.dueIconColor,
            value: '${userData.dueCardsCount}',
            label: 'Due Today',
          ),
        ),
        const SizedBox(width: AppStyles.sectionSpacing),
        Expanded(
          child: StatCard(
            icon: Icons.psychology,
            iconColor: AppColors.decksIconColor,
            value: '${userData.decks.length}',
            label: 'Decks',
          ),
        ),
      ],
    );
  }
}
