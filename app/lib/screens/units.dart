import 'package:flutter/material.dart';

import '../core/gold.dart';
import '../state.dart';
import '../strings.dart';
import 'home.dart';

class UnitsTab extends StatefulWidget {
  const UnitsTab({super.key, required this.state});
  final AppState state;

  @override
  State<UnitsTab> createState() => _UnitsTabState();
}

class _UnitsTabState extends State<UnitsTab> {
  final _value = TextEditingController(text: '1');
  String _from = 'tola';
  String _to = 'g';

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  DropdownButtonFormField<String> _pick(
    S s,
    String label,
    String v,
    ValueChanged<String> on,
  ) => DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: v,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final u in unitKeys)
        DropdownMenuItem(value: u, child: Text(s.unitName(u))),
    ],
    onChanged: (x) => setState(() => on(x!)),
  );

  @override
  Widget build(BuildContext context) {
    final s = S(widget.state.ar);
    final v = tryNum(_value.text);
    final out = (v != null && v >= 0) ? convert(v, _from, _to) : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('convValue'),
          controller: _value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: s.value2),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _pick(s, s.from, _from, (x) => _from = x)),
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: () => setState(() {
                final t = _from;
                _from = _to;
                _to = t;
              }),
            ),
            Expanded(child: _pick(s, s.to, _to, (x) => _to = x)),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: out == null
                ? Text(s.invalid)
                : resultRow(
                    context,
                    s.result,
                    '${num4(out)} ${s.unitName(_to)}',
                    strong: true,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        for (final u in ['kg', 'oz', 'tola', 'mithqal'])
          ListTile(
            dense: true,
            title: Text('1 ${s.unitName(u)}'),
            trailing: Text(
              '${num4(units[u]!)} ${s.gUnit}',
              textDirection: TextDirection.ltr,
            ),
          ),
      ],
    );
  }
}
