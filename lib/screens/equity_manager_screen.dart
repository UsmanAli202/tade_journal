import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../state/trade_journal_store.dart';

class EquityManagerScreen extends StatefulWidget {
  final TradeJournalStore store;

  const EquityManagerScreen({Key? key, required this.store}) : super(key: key);

  @override
  State<EquityManagerScreen> createState() => _EquityManagerScreenState();
}

class _EquityManagerScreenState extends State<EquityManagerScreen> {
  DateTime _selectedMonth = DateTime.now();
  late TextEditingController _capitalController;

  @override
  void initState() {
    super.initState();
    _capitalController = TextEditingController(
      text: widget.store.equityProfile.initialCapital.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _capitalController.dispose();
    super.dispose();
  }

  void _showEditCapitalDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Total Investment'),
        content: TextField(
          controller: _capitalController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Starting Capital (\$)',
            prefixIcon: Icon(Icons.account_balance_wallet_outlined),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () {
              final newCap = double.tryParse(_capitalController.text) ?? widget.store.equityProfile.initialCapital;
              widget.store.updateInitialCapital(newCap);
              Navigator.pop(ctx);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final initialCapital = widget.store.equityProfile.initialCapital;
    final totalPnl = widget.store.totalPnl;
    final currentEquity = widget.store.currentEquity;
    final totalRoi = widget.store.totalRoiPercentage;

    // Monthly data
    final monthlyTrades = widget.store.getTradesForMonth(_selectedMonth);
    final monthlyPnl = widget.store.getMonthlyPnl(_selectedMonth);
    final monthlyRoi = initialCapital > 0 ? (monthlyPnl / initialCapital) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equity Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edit Initial Capital',
            onPressed: _showEditCapitalDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Total Portfolio Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E2838), const Color(0xFF141824)]
                    : [const Color(0xFF1976D2), const Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL ACCOUNT EQUITY',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: _showEditCapitalDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit, size: 12, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Edit Capital',
                              style: TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${currentEquity.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Initial Investment', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('\$${initialCapital.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Overall PnL', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          totalPnl >= 0 ? '+\$${totalPnl.toStringAsFixed(2)}' : '-\$${totalPnl.abs().toStringAsFixed(2)}',
                          style: TextStyle(
                            color: totalPnl >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total ROI', style: TextStyle(color: Colors.white60, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '\${totalRoi >= 0 ? '+' : ''}\${totalRoi.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: totalRoi >= 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Win/Loss Ratio Card
          Row(
            children: [
              Expanded(
                child: _statCard(
                  'Win Rate',
                  '\${widget.store.winRate.toStringAsFixed(1)}%',
                  Icons.pie_chart,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'Wins / Losses',
                  '\${widget.store.totalWins}W / \${widget.store.totalLosses}L',
                  Icons.swap_vert,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Monthly Breakdown Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'End of Month Review',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                      });
                    },
                  ),
                  Text(
                    DateFormat('MMM yyyy').format(_selectedMonth),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Monthly Performance Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Realized PnL:',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      Text(
                        monthlyPnl >= 0 ? '+\$${monthlyPnl.toStringAsFixed(2)}' : '-\$${monthlyPnl.abs().toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: monthlyPnl >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Return on Investment (ROI):',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      Text(
                        '\${monthlyRoi >= 0 ? '+' : ''}\${monthlyRoi.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: monthlyRoi >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trades Executed this Month:',
                        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                      ),
                      Text(
                        '\${monthlyTrades.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Helpful tip
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tracking equity every month helps you assess whether your risk-to-reward ratio and win rate meet your monthly target goals without relying on emotional trading.',
                    style: TextStyle(fontSize: 12, height: 1.4, color: theme.colorScheme.onSurface.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
