import 'package:flutter_test/flutter_test.dart';
import 'package:front_end_test_vista/main.dart';

void main() {
  testWidgets('Vista dashboard displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const VistaApp());

    expect(find.text('VISTA'), findsOneWidget);
    expect(find.text('Welcome to Vista!'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Management'), findsOneWidget);
    expect(find.text('Company Management'), findsOneWidget);
    expect(find.text('Service Management'), findsOneWidget);
  });
}
