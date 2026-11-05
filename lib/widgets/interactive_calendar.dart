import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/trade_journal_store.dart';

class InteractiveCalendar extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final TradeJournalStore store;

  const InteractiveCalendar({
    Key? key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysInMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    final firstDayWeekday = DateTime(currentMonth.year, currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun
    final offset = (firstDayWeekday - 1) % 7; // Align to Mon-Sun

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Month Header with Prev/Next
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    onMonthChanged(DateTime(currentMonth.year, currentMonth.month - 1, 1));
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(currentMonth),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    onMonthChanged(DateTime(currentMonth.year, currentMonth.month + 1, 1));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Weekday Headers
            Row(
              children: dayNames.map((d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ),
              )).toList(),
            ),
            const Divider(height: 16),

            // Calendar Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: offset + daysInMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                if (index < offset) {
                  return const SizedBox.shrink();
                }
                final day = index - offset + 1;
                final cellDate = DateTime(currentMonth.year, currentMonth.month, day);
                final isSelected = cellDate.year == selectedDate.year &&
                    cellDate.month == selectedDate.month &&
                    cellDate.day == selectedDate.day;
                final isToday = DateTime.now().year == cellDate.year &&
                    DateTime.now().month == cellDate.month &&
                    DateTime.now().day == cellDate.day;

                // Check trade status on this day
                final dayTrades = store.getTradesForDate(cellDate);
                final hasTrades = dayTrades.isNotEmpty;
                final dayPnl = dayTrades.fold(0.0, (sum, t) => sum + t.calculatedPnl);

                Color? badgeColor;
                if (hasTrades) {
                  badgeColor = dayPnl >= 0 ? Colors.greenAccent.shade700 : Colors.redAccent.shade700;
                }

                return InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => onDateSelected(cellDate),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : (isToday
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : (isToday
                                ? theme.colorScheme.primary.withOpacity(0.4)
                                : Colors.transparent),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (hasTrades) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? theme.colorScheme.onPrimary : badgeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
