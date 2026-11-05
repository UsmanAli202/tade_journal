# Trading Journal Flutter App

A complete, production-grade Flutter Trading Journal Application featuring calendar trade logging, screenshot upload (up to 3 photos), automated SL/TP profit-loss calculation, Equity Manager with ROI tracking, and Light/Dark mode.

## Features
- **Interactive Calendar (Home View):**
  - Month/Day calendar view with visual indicators on days where trades were taken.
  - Tapping any date navigates to that day's dedicated trade journal page.
- **Date Trades Page & Entry Form:**
  - **Upload Photos:** Add up to 3 chart screenshots/photos per trade.
  - **Trade Reason Box:** Dedicated multi-line input to log trade confluence, technical thesis, session, and psychology.
  - **Price Inputs:** Entry Price, Stop Loss (SL) Price, Take Profit (TP) Price, and Lot Size / Units.
  - **Outcome Identifier:** Tap buttons for **TP HIT 🎯**, **SL HUNTED 💥**, **Break Even ⚖️**, or **Open / Pending ⏳**.
  - **Auto Profit & Loss Calculation:** Automatically computes real-time PnL and displays in high-contrast profit/loss styling based on direction (Buy/Sell) and outcome.
- **Equity Manager:**
  - Enter and edit your total initial investment / portfolio capital.
  - Real-time Total Equity, Realized PnL, and Total ROI %.
  - End-of-month review with monthly PnL, monthly ROI %, and Win Rate statistics.
- **Dark & Light Mode:**
  - Toggle between TradingView-inspired dark theme (`#131722`) and clean modern light theme with a single tap.

## How to Run in Android Studio
1. Unzip `trade_journal_app.zip`.
2. Open Android Studio and select **File > Open**, then choose the `trade_journal` folder.
3. Android Studio will detect the Flutter project and load the Dart analysis server.
4. Run `flutter pub get` in the built-in terminal (or click "Pub get" on the banner in `pubspec.yaml`).
5. Choose an Android Emulator or connected device and click **Run** (`Shift + F10`).
