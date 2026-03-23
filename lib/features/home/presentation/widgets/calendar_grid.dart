import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/models/models.dart';
import '../../../../shared/widgets/shared_widgets.dart';

// Barrel import path note: this file is in features/home/widgets/
// but imports from the lib root using relative paths.

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  /// Map of date → DaySpendLevel for colour-coded dots.
  /// Dates not in the map render with no dot.
  final Map<DateTime, DaySpendLevel> spendLevels;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
    required this.spendLevels,
  });

  static const List<String> _weekdayLabels = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildWeekdayRow(),
        const SizedBox(height: AppSpacing.sm),
        _buildDayGrid(),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    return Row(
      children: _weekdayLabels.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: AppTextStyles.label.copyWith(fontSize: 10),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayGrid() {
    final firstDay = DateTime(month.year, month.month, 1);
    // Weekday: Mon=1 ... Sun=7 → offset so Monday is col 0
    final startOffset = (firstDay.weekday - 1) % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = startOffset + daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNumber = cellIndex - startOffset + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return Expanded(
                  child: _EmptyDayCell(
                    label: _overflowDayLabel(dayNumber, daysInMonth),
                  ),
                );
              }

              final date = DateTime(month.year, month.month, dayNumber);
              final isSelected = _isSameDay(date, selectedDate);
              final spendLevel = spendLevels[
                DateTime(date.year, date.month, date.day)];

              return Expanded(
                child: _DayCell(
                  day: dayNumber,
                  isSelected: isSelected,
                  spendLevel: spendLevel,
                  onTap: () => onDateSelected(date),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Returns the overflowing day number label (prev/next month days).
  String _overflowDayLabel(int dayNumber, int daysInMonth) {
    if (dayNumber < 1) {
      final prevMonthDays = DateTime(month.year, month.month, 0).day;
      return '${prevMonthDays + dayNumber}';
    }
    if (dayNumber > daysInMonth) {
      return '${dayNumber - daysInMonth}';
    }
    return '';
  }
}

// ── Day Cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final DaySpendLevel? spendLevel;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.spendLevel,
    required this.onTap,
  });

  Color get _dotColor {
    switch (spendLevel) {
      case DaySpendLevel.low: return AppColors.spendLow;
      case DaySpendLevel.high: return AppColors.spendHigh;
      case DaySpendLevel.none:
      case null: return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? AppColors.textOnDark
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            SpendDot(color: _dotColor),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayCell extends StatelessWidget {
  final String label;
  const _EmptyDayCell({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
