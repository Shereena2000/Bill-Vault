import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../Settings/constants/sized_box.dart';
import '../../../../../Settings/utils/p_colors.dart';
import '../../../../../Settings/utils/p_text_styles.dart';
import '../../view_model/purchase_detail_vm.dart';

class CalenderWidget extends StatelessWidget {
  const CalenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PurchaseDetailViewModel>(
      builder: (context, provider, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom Calendar Header matching Figma exactly
            SizedBox(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM').format(provider.focusedDay),
                        style: PTextStyles.headlineSmall,
                      ),

                      Text(
                        DateFormat('yyyy').format(provider.focusedDay),
                        style: PTextStyles.displayMedium,
                      ),

                      // Replace your Row with navigation icons with this working version:
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final newFocusedDay = DateTime(
                                provider.focusedDay.year,
                                provider.focusedDay.month - 1,
                              );
                              provider.onPageChanged(newFocusedDay);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.chevron_left,
                                size: 18,
                                color: PColors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              final newFocusedDay = DateTime(
                                provider.focusedDay.year,
                                provider.focusedDay.month + 1,
                              );
                              provider.onPageChanged(newFocusedDay);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizeBoxH(10),
            // Table Calendar
            TableCalendar<DateTime>(
              rowHeight: 40,
              daysOfWeekHeight: 30,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: provider.focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(provider.selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                provider.selectDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                provider.onPageChanged(focusedDay);
              },
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerVisible: false, // Hide default header
              daysOfWeekVisible: true,
              calendarStyle: CalendarStyle(
                // Outside days (previous/next month)
                outsideDaysVisible: true,
                outsideTextStyle: PTextStyles.headlineSmall.copyWith(
                  color: PColors.mediumGray,
                ),
                // Default days
                defaultTextStyle: PTextStyles.headlineSmall,
                // Weekend days
                weekendTextStyle: PTextStyles.headlineSmall,
                // Selected day
                selectedDecoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: PTextStyles.headlineSmall,
                // Today
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: PColors.red, width: 1),
                ),
                todayTextStyle: PTextStyles.headlineSmall,
                // Cell styling
                cellMargin: EdgeInsets.all(7),
                cellPadding: EdgeInsets.zero,
                cellAlignment: Alignment.center,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                // Day headers (Su, Mo, Tu, etc.)
                weekdayStyle: PTextStyles.headlineSmall,
                weekendStyle: PTextStyles.headlineSmall,
              ),
            ),
          ],
        );
      },
    );
  }
}
