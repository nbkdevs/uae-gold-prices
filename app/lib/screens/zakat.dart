import 'package:flutter/material.dart';

import '../core/gold.dart';
import '../state.dart';
import '../strings.dart';
import 'home.dart';

class _Row {
  _Row(String w, this.karat) : weight = TextEditingController(text: w);
  final TextEditingController weight;
  int karat;
  String unit = 'g';
}

class ZakatTab extends StatefulWidget {
  const ZakatTab({super.key, required this.state});
  final AppState state;

  @override
  State<ZakatTab> createState() => _ZakatTabState();
}

class _ZakatTabState extends State<ZakatTab> {
  final _rows = <_Row>[_Row('100', 21)];

  @override
  void dispose() {
    for (final r in _rows) {
      r.weight.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.state.ar);
    final p = widget.state.price24;
    final items = <GoldItem>[];
    for (final r in _rows) {
      final w = tryNum(r.weight.text);
      if (w != null && w > 0) {
        items.add(GoldItem(w, unit: r.unit, karat: r.karat));
      }
    }
    final res = (p != null && items.isNotEmpty) ? zakat(p, items) : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (var i = 0; i < _rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: Key('zw$i'),
                    controller: _rows[i].weight,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(labelText: s.weight),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _rows[i].unit,
                    decoration: InputDecoration(labelText: s.unit),
                    items: [
                      for (final u in unitKeys)
                        DropdownMenuItem(value: u, child: Text(s.unitShort(u))),
                    ],
                    onChanged: (v) => setState(() => _rows[i].unit = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<int>(
                    key: Key('zk$i'),
                    isExpanded: true,
                    initialValue: _rows[i].karat,
                    decoration: InputDecoration(labelText: s.karat),
                    items: [
                      for (final k in karatList)
                        DropdownMenuItem(value: k, child: Text('${k}K')),
                    ],
                    onChanged: (v) => setState(() => _rows[i].karat = v!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _rows.length == 1
                      ? null
                      : () =>
                            setState(() => _rows.removeAt(i).weight.dispose()),
                ),
              ],
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            key: const Key('addItem'),
            icon: const Icon(Icons.add),
            label: Text(s.addItem),
            onPressed: () => setState(() => _rows.add(_Row('', 18))),
          ),
        ),
        const SizedBox(height: 8),
        if (p == null)
          needPrice(context, s)
        else if (res != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  resultRow(
                    context,
                    s.pure,
                    '${num4(res.pureGrams)} ${s.gUnit}',
                  ),
                  resultRow(context, s.value, money(res.value)),
                  resultRow(context, s.nisab, money(res.nisabValue)),
                  const Divider(),
                  Row(
                    children: [
                      Icon(
                        res.due
                            ? Icons.check_circle_outline
                            : Icons.remove_circle_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        res.due ? s.due : s.notDue,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                  resultRow(
                    context,
                    s.zakatOut,
                    '${money(res.zakat)} ${s.cur}',
                    strong: true,
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
