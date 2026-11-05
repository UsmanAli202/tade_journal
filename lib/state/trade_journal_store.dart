import 'package:flutter/material.dart';
import '../models/trade.dart';
import '../models/equity_profile.dart';

class TradeJournalStore extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  // Equity
  final EquityProfile equityProfile = EquityProfile(initialCapital: 10000.0);

  void updateInitialCapital(double amount) {
    equityProfile.initialCapital = amount;
    notifyListeners();
  }

  // Trades List
  final List<Trade> _trades = [];
  List<Trade> get trades => List.unmodifiable(_trades);

  List<Trade> getTradesForDate(DateTime date) {
    return _trades.where((t) =>
      t.date.year == date.year &&
      t.date.month == date.month &&
      t.date.day == date.day
    ).toList();
  }

  void addTrade(Trade trade) {
    trade.recalculatePnl();
    _trades.add(trade);
    notifyListeners();
  }

  void updateTrade(Trade updatedTrade) {
    final index = _trades.indexWhere((t) => t.id == updatedTrade.id);
    if (index != -1) {
      updatedTrade.recalculatePnl();
      _trades[index] = updatedTrade;
      notifyListeners();
    }
  }

  void deleteTrade(String id) {
    _trades.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // Calculated Stats
  double get totalPnl => _trades.fold(0.0, (sum, t) => sum + t.calculatedPnl);
  double get currentEquity => equityProfile.initialCapital + totalPnl;
  double get totalRoiPercentage => equityProfile.initialCapital > 0 
      ? (totalPnl / equityProfile.initialCapital) * 100 
      : 0.0;

  int get totalWins => _trades.where((t) => t.outcome == TradeOutcome.tpHit).length;
  int get totalLosses => _trades.where((t) => t.outcome == TradeOutcome.slHunt).length;
  int get totalBreakEvens => _trades.where((t) => t.outcome == TradeOutcome.breakEven).length;

  double get winRate {
    final closed = totalWins + totalLosses;
    if (closed == 0) return 0.0;
    return (totalWins / closed) * 100;
  }

  // Filter for specific month
  List<Trade> getTradesForMonth(DateTime month) {
    return _trades.where((t) =>
      t.date.year == month.year && t.date.month == month.month
    ).toList();
  }

  double getMonthlyPnl(DateTime month) {
    return getTradesForMonth(month).fold(0.0, (sum, t) => sum + t.calculatedPnl);
  }
}
