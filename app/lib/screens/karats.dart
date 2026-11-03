import 'package:flutter/material.dart';

import '../core/gold.dart';
import '../state.dart';
import '../strings.dart';
import 'home.dart';

class KaratsTab extends StatelessWidget {
  const KaratsTab({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final s = S(state.ar);
    final p = state.price24;
    final t = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (p == null)
          needPrice(context, s)
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Table(
                columnWidths: const {0: FlexColumnWidth(1.1)},
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [s.karat, s.perGram, s.perTola, s.perOunce]
                        .map(
                          (h) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(h, style: t.labelLarge),
                          ),
                        )
                        .toList(),
                  ),
                  for (final r in priceTable(p))
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '${r.karat}K · ${r.hallmark}',
                            style: t.titleSmall,
                          ),
                        ),
                        Text(
                          money(r.perGram),
                          key: Key('k${r.karat}g'),
                          textDirection: TextDirection.ltr,
                        ),
                        Text(
                          money(r.perTola),
                          textDirection: TextDirection.ltr,
                        ),
                        Text(
                          money(r.perOunce),
                          textDirection: TextDirection.ltr,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        noteText(context, s),
      ],
    );
  }
}
