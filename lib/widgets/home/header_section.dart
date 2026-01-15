import 'package:flutter/material.dart';
import '../../models/user_data.dart';
import '../../widgets/stat_card.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_styles.dart';

class HeaderSection extends StatelessWidget {
  final UserData userData;
  final bool isDark;

  const HeaderSection({
    super.key,
    required this.userData,
    required this.isDark,
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
      padding: const EdgeInsets.fromLTRB(
        AppStyles.defaultPadding,
        12,
        AppStyles.defaultPadding,
        AppStyles.defaultPadding,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SigmaCards', style: AppStyles.headerTitle),
                    const SizedBox(height: 4),
                    Text('Keep learning every day', style: AppStyles.headerSubtitle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppStyles.defaultPadding),
          _buildStatsRow(),
        ],
      ),
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
            label: 'Your Decks',
          ),
        ),
      ],
    );
  }
}
