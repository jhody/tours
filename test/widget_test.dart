// Esta es una prueba básica del widget Flutter.
//
// Para realizar una interacción con un widget en tu prueba, usa WidgetTester
// utilidad en el paquete flutter_test. Por ejemplo, puedes enviar toque y desplazamiento
// gestos. También puede utilizar WidgetTester para buscar widgets secundarios en el widget.
// árbol, lee el texto y verifica que los valores de las propiedades del widget sean correctos.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tours/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ToursApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
