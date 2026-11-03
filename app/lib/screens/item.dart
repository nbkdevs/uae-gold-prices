import 'package:flutter/material.dart';

import '../core/gold.dart';
import '../state.dart';
import '../strings.dart';
import 'home.dart';

class ItemTab extends StatefulWidget {
  const ItemTab({super.key, required this.state});
  final AppState state;

  @override
  State<ItemTab> createState() => _ItemTabState();
}

class _ItemTabState extends State<ItemTab> {
  final _weight = TextEditingController(text: '10');
  final _making = TextEditingController(text: '0');
  String _unit = 'g';
  int _karat = 21;
  MakingType _type = MakingType.perGram;
  bool _vat = true;

  @override
  void dispose() {
    _weight.dispose();
    _making.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.state.ar);
    final p = widget.state.price24;
    final w = tryNum(_weight.text);
    final m = tryNum(_making.text) ?? 0;
    ItemPrice? r;
    if (p != null && w != null && w > 0 && m >= 0) {
      r = itemPrice(
        price24: p,
        weight: w,
        unit: _unit,
        karat: _karat,
        making: m,
        makingType: _type,
        vatRate: _vat ? uaeVatRate : 0,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('itemWeight'),
                controller: _weight,
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
                initialValue: _unit,
                decoration: InputDecoration(labelText: s.unit),
                items: [
                  for (final u in unitKeys)
                    DropdownMenuItem(value: u, child: Text(s.unitName(u))),
                ],
                onChanged: (v) => setState(() => _unit = v!),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                key: const Key('itemKarat'),
                isExpanded: true,
                initialValue: _karat,
                decoration: InputDecoration(labelText: s.karat),
                items: [
                  for (final k in karatList)
                    DropdownMenuItem(value: k, child: Text('${k}K')),
                ],
                onChanged: (v) => setState(() => _karat = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('itemMaking'),
          controller: _making,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: s.making),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        SegmentedButton<MakingType>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: MakingType.perGram, label: Text(s.mPerGram)),
            ButtonSegment(value: MakingType.percent, label: Text(s.mPercent)),
            ButtonSegment(value: MakingType.fixed, label: Text(s.mFixed)),
          ],
          selected: {_type},
          onSelectionChanged: (v) => setState(() => _type = v.first),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(s.vatOn),
          subtitle: Text(s.vatHint),
          value: _vat,
          onChanged: (v) => setState(() => _vat = v),
        ),
        if (p == null)
          needPrice(context, s)
        else if (r == null)
          Text(
            s.invalid,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  resultRow(
                    context,
                    '${s.karat} ${_karat}K / ${s.gUnit}',
                    money(r.pricePerGram),
                  ),
                  resultRow(context, s.metal, money(r.metal)),
                  resultRow(context, s.making, money(r.making)),
                  resultRow(context, s.vat, money(r.vat)),
                  const Divider(),
                  Semantics(
                    label: 'total',
                    child: resultRow(
                      context,
                      s.total,
                      '${money(r.total)} ${s.cur}',
                      strong: true,
                    ),
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
