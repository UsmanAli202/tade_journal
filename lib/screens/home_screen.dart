import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/trade_journal_store.dart';
import '../widgets/interactive_calendar.dart';
import 'date_trades_page.dart';
import 'equity_manager_screen.dart';
import 'trade_form_screen.dart';

class HomeScreen extends StatefulWidget {
  final TradeJournalStore store;

  const HomeScreen({Key? key, required this.store}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.store.isDarkMode;
    final tradesOnSelected = widget.store.getTradesForDate(_selectedDate);
    final dayPnl = tradesOnSelected.fold(0.0, (sum, t) => sum + t.calculatedPnl);
    final selectedDateStr = DateFormat('MMMM d, yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.candlestick_chart, color: Colors.greenAccent),
            SizedBox(width: 8),
            Text('TradeJournal', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              widget.store.toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Equity Manager',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EquityManagerScreen(store: widget.store),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Quick Stats Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E222D) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Equity', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 2),
                        Text(
                          '\$${widget.store.currentEquity.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total P&L', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                        const SizedBox(height: 2),
                        Text(
                          widget.store.totalPnl >= 0
                              ? '+\$${widget.store.totalPnl.toStringAsFixed(2)}'
                              : '-\$${widget.store.totalPnl.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.store.totalPnl >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.pie_chart, size: 16),
                      label: const Text('Equity', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EquityManagerScreen(store: widget.store),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Calendar Component
              InteractiveCalendar(
                currentMonth: _currentMonth,
                selectedDate: _selectedDate,
                store: widget.store,
                onMonthChanged: (newMonth) {
                  setState(() {
                    _currentMonth = newMonth;
                  });
                },
                onDateSelected: (newDate) {
                  setState(() {
                    _selectedDate = newDate;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DateTradesPage(
                        date: newDate,
                        store: widget.store,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Bottom Section: Summary for Selected Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selected: $selectedDateStr",
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Open Date View'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DateTradesPage(
                            date: _selectedDate,
                            store: widget.store,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick card for selected date
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: tradesOnSelected.isEmpty
                            ? Colors.grey.withOpacity(0.15)
                            : (dayPnl >= 0 ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15)),
                        child: Icon(
                          tradesOnSelected.isEmpty
                              ? Icons.calendar_view_day
                              : (dayPnl >= 0 ? Icons.trending_up : Icons.trending_down),
                          color: tradesOnSelected.isEmpty
                              ? Colors.grey
                              : (dayPnl >= 0 ? Colors.green : Colors.red),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tradesOnSelected.isEmpty
                                  ? 'No trades for this date'
                                  : "${tradesOnSelected.length} Trade${tradesOnSelected.length == 1 ? '' : 's'} recorded",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tradesOnSelected.isEmpty
                                  ? 'Tap to log reasons, prices & chart photos'
                                  : "Day PnL: ${dayPnl >= 0 ? '+' : ''}\$${dayPnl.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 12,
                                color: tradesOnSelected.isEmpty
                                    ? theme.colorScheme.onSurface.withOpacity(0.6)
                                    : (dayPnl >= 0 ? Colors.green : Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.blueAccent),
                        tooltip: 'Add Trade on this Date',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TradeFormScreen(
                                selectedDate: _selectedDate,
                                store: widget.store,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Log Trade'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TradeFormScreen(
                selectedDate: _selectedDate,
                store: widget.store,
              ),
            ),
          );
        },
      ),
    );
  }
}