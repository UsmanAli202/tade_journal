import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../models/trade.dart';
import '../state/trade_journal_store.dart';

class TradeFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Trade? existingTrade;
  final TradeJournalStore store;

  const TradeFormScreen({
    Key? key,
    required this.selectedDate,
    this.existingTrade,
    required this.store,
  }) : super(key: key);

  @override
  State<TradeFormScreen> createState() => _TradeFormScreenState();
}

class _TradeFormScreenState extends State<TradeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _pairController;
  late TextEditingController _entryController;
  late TextEditingController _slController;
  late TextEditingController _tpController;
  late TextEditingController _sizeController;
  late TextEditingController _reasonController;

  TradeDirection _direction = TradeDirection.buy;
  TradeOutcome _outcome = TradeOutcome.pending;
  final List<Uint8List> _images = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final t = widget.existingTrade;
    _pairController = TextEditingController(text: t?.pair ?? 'EUR/USD');
    _entryController = TextEditingController(text: t != null && t.entryPrice != 0 ? t.entryPrice.toString() : '');
    _slController = TextEditingController(text: t != null && t.slPrice != 0 ? t.slPrice.toString() : '');
    _tpController = TextEditingController(text: t != null && t.tpPrice != 0 ? t.tpPrice.toString() : '');
    _sizeController = TextEditingController(text: t?.positionSize.toString() ?? '1.0');
    _reasonController = TextEditingController(text: t?.reason ?? '');

    if (t != null) {
      _direction = t.direction;
      _outcome = t.outcome;
      _images.addAll(t.imageBytesList);
    }
  }

  @override
  void dispose() {
    _pairController.dispose();
    _entryController.dispose();
    _slController.dispose();
    _tpController.dispose();
    _sizeController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 photos allowed per trade entry.')),
      );
      return;
    }

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _images.add(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo selection: \$e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  double _computePreviewPnl(TradeOutcome outcome) {
    final entry = double.tryParse(_entryController.text) ?? 0.0;
    final sl = double.tryParse(_slController.text) ?? 0.0;
    final tp = double.tryParse(_tpController.text) ?? 0.0;
    final size = double.tryParse(_sizeController.text) ?? 1.0;

    if (outcome == TradeOutcome.pending || outcome == TradeOutcome.breakEven) return 0.0;

    double delta = 0.0;
    if (outcome == TradeOutcome.tpHit) {
      delta = _direction == TradeDirection.buy ? (tp - entry) : (entry - tp);
    } else if (outcome == TradeOutcome.slHunt) {
      delta = _direction == TradeDirection.buy ? (sl - entry) : (entry - sl);
    }
    return delta * size;
  }

  void _saveTrade() {
    if (!_formKey.currentState!.validate()) return;

    final entry = double.parse(_entryController.text);
    final sl = double.parse(_slController.text);
    final tp = double.parse(_tpController.text);
    final size = double.tryParse(_sizeController.text) ?? 1.0;

    final trade = Trade(
      id: widget.existingTrade?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: widget.selectedDate,
      pair: _pairController.text.trim().toUpperCase(),
      direction: _direction,
      entryPrice: entry,
      slPrice: sl,
      tpPrice: tp,
      positionSize: size,
      reason: _reasonController.text.trim(),
      outcome: _outcome,
      imageBytesList: _images,
    );

    if (widget.existingTrade == null) {
      widget.store.addTrade(trade);
    } else {
      widget.store.updateTrade(trade);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formattedDate = DateFormat('EEEE, MMM d, yyyy').format(widget.selectedDate);
    final currentPnl = _computePreviewPnl(_outcome);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingTrade == null ? 'New Trade Entry' : 'Edit Trade'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Trade',
            onPressed: _saveTrade,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Date Chip & Direction Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E222D) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Pair & Buy/Sell Segment
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _pairController,
                    decoration: const InputDecoration(
                      labelText: 'Trading Pair / Symbol',
                      hintText: 'e.g., EUR/USD, XAU/USD, BTC',
                      prefixIcon: Icon(Icons.currency_exchange),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SegmentedButton<TradeDirection>(
                    segments: const [
                      ButtonSegment(value: TradeDirection.buy, label: Text('BUY')),
                      ButtonSegment(value: TradeDirection.sell, label: Text('SELL')),
                    ],
                    selected: {_direction},
                    onSelectionChanged: (newVal) {
                      setState(() {
                        _direction = newVal.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.selected)) {
                          return _direction == TradeDirection.buy ? Colors.green.shade700 : Colors.red.shade700;
                        }
                        return null;
                      }),
                      foregroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                        if (states.contains(MaterialState.selected)) return Colors.white;
                        return null;
                      }),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Photo Upload Section (Max 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Screenshots / Charts (\${_images.length}/3 max)',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (_images.length < 3)
                  TextButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: const Text('Upload Photo'),
                    onPressed: _pickImage,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2C) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor.withOpacity(0.3), style: BorderStyle.solid),
              ),
              child: _images.isEmpty
                  ? Center(
                      child: InkWell(
                        onTap: _pickImage,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 36, color: theme.colorScheme.primary),
                            const SizedBox(height: 6),
                            Text(
                              'Tap to upload chart screenshot (Max 3)',
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      scrollDirection: Axis.horizontal,
                      itemCount: _images.length + (_images.length < 3 ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        if (idx == _images.length) {
                          return InkWell(
                            onTap: _pickImage,
                            child: Container(
                              width: 90,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.colorScheme.primary.withOpacity(0.5)),
                                color: theme.colorScheme.primary.withOpacity(0.05),
                              ),
                              child: const Icon(Icons.add_a_photo, size: 28),
                            ),
                          );
                        }
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _images[idx],
                                width: 120,
                                height: 94,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 2,
                              right: 2,
                              child: InkWell(
                                onTap: () => _removeImage(idx),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),

            // Trade Reason Section
            Text(
              'Trade Reason & Confluence',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe your entry logic, setup (Order block, FVG, Trendline break, Liquidity sweep), session, and mindset...',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Please describe the trade reason' : null,
            ),
            const SizedBox(height: 20),

            // Price Inputs: Entry, SL, TP, Size
            Text(
              'Trade Execution Prices',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _entryController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Entry Price',
                      prefixIcon: Icon(Icons.login, size: 18),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _slController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'SL Price',
                      prefixIcon: const Icon(Icons.security, size: 18, color: Colors.redAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _tpController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'TP Price',
                      prefixIcon: const Icon(Icons.flag, size: 18, color: Colors.greenAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Lot Size / Units / Multiplier',
                hintText: 'e.g., 1.0 (Standard Lot), 0.1, or 100 shares',
                prefixIcon: Icon(Icons.pie_chart_outline),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) => double.tryParse(v ?? '') == null ? 'Invalid lot size' : null,
            ),
            const SizedBox(height: 24),

            // Trade Outcome Buttons
            Text(
              'Trade Result & Outcome',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildOutcomeButton(
                  title: 'TP HIT 🎯',
                  targetOutcome: TradeOutcome.tpHit,
                  color: Colors.green.shade600,
                  activeColor: Colors.green.shade700,
                ),
                _buildOutcomeButton(
                  title: 'SL HUNTED 💥',
                  targetOutcome: TradeOutcome.slHunt,
                  color: Colors.red.shade600,
                  activeColor: Colors.red.shade700,
                ),
                _buildOutcomeButton(
                  title: 'Break Even ⚖️',
                  targetOutcome: TradeOutcome.breakEven,
                  color: Colors.amber.shade700,
                  activeColor: Colors.amber.shade800,
                ),
                _buildOutcomeButton(
                  title: 'Open / Pending ⏳',
                  targetOutcome: TradeOutcome.pending,
                  color: Colors.grey.shade600,
                  activeColor: Colors.grey.shade700,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Automatic Calculation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _outcome == TradeOutcome.tpHit
                    ? Colors.green.withOpacity(0.12)
                    : (_outcome == TradeOutcome.slHunt
                        ? Colors.red.withOpacity(0.12)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _outcome == TradeOutcome.tpHit
                      ? Colors.green
                      : (_outcome == TradeOutcome.slHunt ? Colors.red : theme.dividerColor.withOpacity(0.4)),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculated Profit / Loss',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _outcome == TradeOutcome.pending
                            ? 'Outcome Pending'
                            : (currentPnl >= 0
                                ? '+\$${currentPnl.toStringAsFixed(2)}'
                                : '-\$${currentPnl.abs().toStringAsFixed(2)}'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: _outcome == TradeOutcome.pending
                              ? theme.colorScheme.onSurface
                              : (currentPnl >= 0 ? Colors.greenAccent.shade400 : Colors.redAccent.shade400),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _outcome == TradeOutcome.tpHit
                        ? Icons.trending_up
                        : (_outcome == TradeOutcome.slHunt ? Icons.trending_down : Icons.schedule),
                    size: 36,
                    color: _outcome == TradeOutcome.tpHit
                        ? Colors.green
                        : (_outcome == TradeOutcome.slHunt ? Colors.red : Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _saveTrade,
              child: Text(
                widget.existingTrade == null ? 'Save Trade Log' : 'Update Trade Log',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeButton({
    required String title,
    required TradeOutcome targetOutcome,
    required Color color,
    required Color activeColor,
  }) {
    final isSelected = _outcome == targetOutcome;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? activeColor : Colors.transparent,
        foregroundColor: isSelected ? Colors.white : color,
        elevation: isSelected ? 3 : 0,
        side: BorderSide(color: color, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _outcome = targetOutcome;
        });
      },
      child: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      ),
    );
  }
}
