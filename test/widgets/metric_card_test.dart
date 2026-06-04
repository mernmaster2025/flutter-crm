import 'package:flutter/material.dart';
import 'package:flutter_crm/core/theme/app_colors.dart';
import 'package:flutter_crm/widgets/crm_components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MetricCard renders title and value', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'Revenue',
            value: r'$1.2M',
            icon: Icons.payments_rounded,
            accent: AppColors.indigo,
          ),
        ),
      ),
    );

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text(r'$1.2M'), findsOneWidget);
  });
}
