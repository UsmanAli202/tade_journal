import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'state/trade_journal_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TradeJournalApp());
}

class TradeJournalApp extends StatefulWidget {
  const TradeJournalApp({Key? key}) : super(key: key);

  @override
  State<TradeJournalApp> createState() => _TradeJournalAppState();
}

class _TradeJournalAppState extends State<TradeJournalApp> {
  final TradeJournalStore _store = TradeJournalStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trade Journal',
      debugShowCheckedModeBanner: false,
      themeMode: _store.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF2962FF),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2962FF),
          secondary: Color(0xFF00C853),
          surface: Colors.white,
          background: Color(0xFFF7F9FC),
          onPrimary: Colors.white,
        ),
        cardTheme: CardThemeData(color: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD0D7DE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE1E4E8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E222D),
          elevation: 0.5,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        primaryColor: const Color(0xFF2962FF),
        scaffoldBackgroundColor: const Color(0xFF131722), // TradingView dark theme vibe
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2962FF),
          secondary: Color(0xFF00E676),
          surface: Color(0xFF1E222D),
          background: Color(0xFF131722),
          onPrimary: Colors.white,
          surfaceVariant: Color(0xFF2A2E39),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E222D),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E222D),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2E39)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2E39)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.8),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E222D),
          foregroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(store: _store),
    );
  }
}
