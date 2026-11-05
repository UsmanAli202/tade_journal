import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trade.dart';
import '../state/trade_journal_store.dart';
import 'trade_form_screen.dart';

class DateTradesPage extends StatelessWidget {
  final DateTime date;
  final TradeJournalStore store;

  const DateTradesPage({
    Key? key,
    required this.date,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dayTrades = store.getTradesForDate(date);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(date);
    final dayTotalPnl = dayTrades.fold(0.0, (sum, t) => sum + t.calculatedPnl);
    final tradesCountText = "${dayTrades.length} Trade${dayTrades.length == 1 ? '' : 's'} Logged";

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMM d, yyyy').format(date)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Trade on this Date',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TradeFormScreen(
                    selectedDate: date,
                    store: store,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header summary for this specific date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B202E) : Colors.blueGrey.shade50,
              border: Border(bottom: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tradesCountText,
                      style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: dayTotalPnl >= 0
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: dayTotalPnl >= 0 ? Colors.green : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dayTotalPnl >= 0
                        ? '+\$${dayTotalPnl.toStringAsFixed(2)}'
                        : '-\$${dayTotalPnl.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: dayTotalPnl >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trades list or Empty state
          Expanded(
            child: dayTrades.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.query_stats_outlined, size: 64, color: theme.colorScheme.primary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    const Text(
                      'No trades recorded for this date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the button below to log your trade reason, entry, SL, TP, and chart screenshots.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Log First Trade'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TradeFormScreen(
                              selectedDate: date,
                              store: store,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dayTrades.length,
              itemBuilder: (context, idx) {
                final trade = dayTrades[idx];
                return _buildTradeCard(context, trade);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Log Trade',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TradeFormScreen(
                selectedDate: date,
                store: store,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTradeCard(BuildContext context, Trade trade) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color badgeColor;
    String outcomeLabel;
    IconData outcomeIcon;

    switch (trade.outcome) {
      case TradeOutcome.tpHit:
        badgeColor = Colors.green;
        outcomeLabel = 'TP HIT';
        outcomeIcon = Icons.check_circle_outline;
        break;
      case TradeOutcome.slHunt:
        badgeColor = Colors.red;
        outcomeLabel = 'SL HUNTED';
        outcomeIcon = Icons.cancel_outlined;
        break;
      case TradeOutcome.breakEven:
        badgeColor = Colors.amber;
        outcomeLabel = 'BREAK EVEN';
        outcomeIcon = Icons.remove_circle_outline;
        break;
      case TradeOutcome.pending:
        badgeColor = Colors.grey;
        outcomeLabel = 'PENDING';
        outcomeIcon = Icons.hourglass_empty;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Pair, Buy/Sell, Outcome badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trade.direction == TradeDirection.buy ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: trade.direction == TradeDirection.buy ? Colors.green : Colors.red,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trade.pair,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(outcomeIcon, size: 14, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        outcomeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Execution details: Entry, SL, TP, PnL
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF171A24) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _priceItem('Entry', trade.entryPrice.toString()),
                  _priceItem('SL', trade.slPrice.toString(), textColor: Colors.redAccent),
                  _priceItem('TP', trade.tpPrice.toString(), textColor: Colors.greenAccent),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('P&L', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 2),
                      Text(
                        trade.outcome == TradeOutcome.pending
                            ? '---'
                            : (trade.calculatedPnl >= 0
                            ? '+\$${trade.calculatedPnl.toStringAsFixed(2)}'
                            : '-\$${trade.calculatedPnl.abs().toStringAsFixed(2)}'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: trade.calculatedPnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Trade Reason Box
            const Text(
              'Trade Reason:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF222736) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Text(
                trade.reason.isEmpty ? 'No reason entered.' : trade.reason,
                style: const TextStyle(fontSize: 13, height: 1.3),
              ),
            ),

            // Photos Preview if available
            if (trade.imageBytesList.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${trade.imageBytesList.length} Chart Screenshot(s):',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: trade.imageBytesList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        // Fullscreen dialog
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.memory(trade.imageBytesList[i]),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          trade.imageBytesList[i],
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 8),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TradeFormScreen(
                          selectedDate: trade.date,
                          existingTrade: trade,
                          store: store,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  onPressed: () {
                    store.deleteTrade(trade.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceItem(String label, String value, {Color? textColor}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
      ],
    );
  }
}