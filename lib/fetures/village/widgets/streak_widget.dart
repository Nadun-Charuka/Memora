import 'package:flutter/material.dart';
import 'package:memora/fetures/village/model/village_model.dart';

/// Beautiful streak indicator widget for home screen
class StreakWidget extends StatelessWidget {
  final Village village;
  final String currentUserId;

  const StreakWidget({
    super.key,
    required this.village,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    if (!village.isActive) return const SizedBox.shrink();

    final streakLevel = village.streakLevel;
    final didIContribute = village.didUserContributeToday(currentUserId);
    final isPartner1 = currentUserId == village.partner1Id;
    final didPartnerContribute = isPartner1
        ? village.didPartner2ContributeToday
        : village.didPartner1ContributeToday;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: _getStreakGradient(village.currentStreak),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStreakColor(
              village.currentStreak,
            ).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            children: [
              // Streak Icon & Number
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    streakLevel.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Streak Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${village.currentStreak}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Day Streak',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      streakLevel.displayName,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Best Record Badge
              if (village.maxStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '👑',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${village.maxStreak}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Best',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Contribution Status
          if (village.hasActiveStreak) ...[
            const SizedBox(height: 16),
            _buildContributionStatus(didIContribute, didPartnerContribute),
          ],

          // Warning if streak in danger
          if (village.isStreakInDanger && village.currentStreak > 0) ...[
            const SizedBox(height: 12),
            _buildStreakWarning(),
          ],
        ],
      ),
    );
  }

  Widget _buildContributionStatus(
    bool didIContribute,
    bool didPartnerContribute,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Current User Status
          _buildUserContributionBadge(
            label: 'You',
            contributed: didIContribute,
          ),

          // Divider
          Container(
            width: 2,
            height: 30,
            color: Colors.white.withValues(alpha: 0.3),
          ),

          // Partner Status
          _buildUserContributionBadge(
            label: 'Partner',
            contributed: didPartnerContribute,
          ),
        ],
      ),
    );
  }

  Widget _buildUserContributionBadge({
    required String label,
    required bool contributed,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: contributed
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: Center(
            child: Icon(
              contributed ? Icons.check_circle : Icons.circle_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          contributed ? 'Done ✓' : 'Pending',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStreakWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Streak in danger! Add a memory today',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get gradient color based on streak count
  LinearGradient _getStreakGradient(int streak) {
    if (streak >= 100) {
      // Legendary - Purple/Gold
      return const LinearGradient(
        colors: [Color(0xFF9333EA), Color(0xFFEAB308)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 50) {
      // Master - Deep Purple
      return const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFFA855F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 30) {
      // Dedicated - Pink/Purple
      return const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 14) {
      // Committed - Pink
      return const LinearGradient(
        colors: [Color(0xFFF472B6), Color(0xFFEC4899)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 7) {
      // Promising - Orange/Pink
      return const LinearGradient(
        colors: [Color(0xFFFB923C), Color(0xFFF472B6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else if (streak >= 3) {
      // Starting - Orange
      return const LinearGradient(
        colors: [Color(0xFFFB923C), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Newbie - Green
      return const LinearGradient(
        colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
  }

  /// Get base color for shadow
  Color _getStreakColor(int streak) {
    if (streak >= 100) return const Color(0xFF9333EA);
    if (streak >= 50) return const Color(0xFF7C3AED);
    if (streak >= 30) return const Color(0xFFEC4899);
    if (streak >= 14) return const Color(0xFFF472B6);
    if (streak >= 7) return const Color(0xFFFB923C);
    if (streak >= 3) return const Color(0xFFF97316);
    return const Color(0xFF22C55E);
  }
}
