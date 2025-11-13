import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:wallet_frontend/app.dart';
import 'package:wallet_frontend/providers/wallet_provider.dart';

void main() {
  Widget _wrap() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const WalletApp(),
    );
  }

  testWidgets('Bottom navigation switches tabs', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.text('Recent Transactions'), findsOneWidget);

    // Navigate to Transactions
    await tester.tap(find.byIcon(Icons.list_alt_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Add Category'), findsNothing); // should be on Transactions tab (no add category button)

    // Navigate to Categories
    await tester.tap(find.byIcon(Icons.category_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Add Category'), findsOneWidget);
  });

  testWidgets('FAB opens add transaction sheet', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
  });
}
