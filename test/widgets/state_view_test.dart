import 'package:busiserve_app/core/errors/failure.dart';
import 'package:busiserve_app/core/state/view_state.dart';
import 'package:busiserve_app/core/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  Widget view(ViewState<String> state, {VoidCallback? onRetry}) => _wrap(
        StateView<String>(
          state: state,
          onRetry: onRetry,
          emptyTitle: 'Nothing yet',
          builder: (data) => Text('data: $data'),
        ),
      );

  testWidgets('loading', (tester) async {
    await tester.pumpWidget(view(const LoadingState()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('success', (tester) async {
    await tester.pumpWidget(view(const SuccessState('hello')));
    expect(find.text('data: hello'), findsOneWidget);
  });

  testWidgets('empty', (tester) async {
    await tester.pumpWidget(view(const EmptyState()));
    expect(find.text('Nothing yet'), findsOneWidget);
  });

  testWidgets('retryable error shows retry and calls it', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      view(const ErrorState(Failure('Offline', retryable: true)), onRetry: () => retried++),
    );
    expect(find.text('Offline'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('non-retryable error hides retry', (tester) async {
    await tester.pumpWidget(view(const ErrorState(Failure('No access')), onRetry: () {}));
    expect(find.text('No access'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
  });
}
