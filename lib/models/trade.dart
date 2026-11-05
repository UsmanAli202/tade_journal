import 'dart:typed_data';

enum TradeDirection { buy, sell }
enum TradeOutcome { pending, tpHit, slHunt, breakEven }

class Trade {
  final String id;
  final DateTime date;
  String pair;
  TradeDirection direction;
  double entryPrice;
  double slPrice;
  double tpPrice;
  double positionSize; // Lot size / units / contracts
  String reason;
  TradeOutcome outcome;
  double calculatedPnl;
  List<Uint8List> imageBytesList; // Stored as bytes for cross-platform/Android preview

  Trade({
    required this.id,
    required this.date,
    this.pair = 'EUR/USD',
    this.direction = TradeDirection.buy,
    this.entryPrice = 0.0,
    this.slPrice = 0.0,
    this.tpPrice = 0.0,
    this.positionSize = 1.0,
    this.reason = '',
    this.outcome = TradeOutcome.pending,
    this.calculatedPnl = 0.0,
    List<Uint8List>? imageBytesList,
  }) : imageBytesList = imageBytesList ?? [];

  /// Auto-calculates Profit / Loss based on Direction, Entry, SL, TP, Position Size, and Outcome
  void recalculatePnl() {
    if (outcome == TradeOutcome.pending) {
      calculatedPnl = 0.0;
      return;
    }
    if (outcome == TradeOutcome.breakEven) {
      calculatedPnl = 0.0;
      return;
    }

    double deltaPrice = 0.0;
    if (outcome == TradeOutcome.tpHit) {
      if (direction == TradeDirection.buy) {
        deltaPrice = tpPrice - entryPrice;
      } else {
        deltaPrice = entryPrice - tpPrice;
      }
    } else if (outcome == TradeOutcome.slHunt) {
      if (direction == TradeDirection.buy) {
        deltaPrice = slPrice - entryPrice; // Will naturally be negative
      } else {
        deltaPrice = entryPrice - slPrice; // Will naturally be negative
      }
    }

    // Multiply by position size or units (standardized)
    calculatedPnl = deltaPrice * positionSize;
  }
}
