import 'package:flutter/material.dart';

import '../state.dart';
import '../strings.dart';
import 'about.dart';
import 'item.dart';
import 'karats.dart';
import 'units.dart';
import 'zakat.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  late final TextEditingController _price = TextEditingController(
    text: widget.state.priceText,
  );

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.state;
    final s = S(st.ar);
    final tabs = [
      KaratsTab(state: st),
      ItemTab(state: st),
      ZakatTab(state: st),
      UnitsTab(state: st),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
        actions: [
          TextButton(
            key: const Key('langToggle'),
            onPressed: st.toggleLang,
            child: Text(s.toggle),
          ),
          IconButton(
            key: const Key('aboutButton'),
            tooltip: s.about,
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => AboutScreen(state: st)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('priceField'),
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: s.price,
                          suffixText: s.cur,
                          prefixIcon: const Icon(Icons.payments_outlined),
                        ),
                        onChanged: st.setPrice,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(value: false, label: Text(s.perGramOpt)),
                        ButtonSegment(value: true, label: Text(s.perOzOpt)),
                      ],
                      selected: {st.perOunce},
                      onSelectionChanged: (v) => st.setPerOunce(v.first),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    s.priceHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: IndexedStack(index: _tab, children: tabs),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.table_chart_outlined),
            label: s.tTable,
          ),
          NavigationDestination(
            icon: const Icon(Icons.diamond_outlined),
            label: s.tItem,
          ),
          NavigationDestination(
            icon: const Icon(Icons.volunteer_activism_outlined),
            label: s.tZakat,
          ),
          NavigationDestination(
            icon: const Icon(Icons.swap_horiz),
            label: s.tConv,
          ),
        ],
      ),
    );
  }
}

/// Shared helpers for the tabs.
Widget needPrice(BuildContext context, S s) => Card(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        const Icon(Icons.info_outline),
        const SizedBox(width: 12),
        Expanded(child: Text(s.needPrice)),
      ],
    ),
  ),
);

Widget resultRow(
  BuildContext context,
  String label,
  String value, {
  bool strong = false,
}) {
  final t = Theme.of(context).textTheme;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: strong ? t.titleMedium : t.bodyLarge),
        ),
        Text(
          value,
          textDirection: TextDirection.ltr,
          style: (strong ? t.titleLarge : t.bodyLarge)?.copyWith(
            fontWeight: strong ? FontWeight.bold : null,
            color: strong ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
      ],
    ),
  );
}

Widget noteText(BuildContext context, S s) => Padding(
  padding: const EdgeInsets.only(top: 12),
  child: Text(s.note, style: Theme.of(context).textTheme.bodySmall),
);

const unitKeys = ['g', 'kg', 'oz', 'tola', 'mithqal'];
const karatList = [24, 22, 21, 18, 14];
