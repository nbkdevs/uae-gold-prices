import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../state.dart';
import '../strings.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.state});
  final AppState state;

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final s = S(state.ar);
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(s.about)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: cs.primaryContainer,
              child: Icon(
                Icons.calculate_outlined,
                size: 44,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(child: Text(s.title, style: t.headlineSmall)),
          Center(
            child: Text('${s.version} ${AppInfo.version}', style: t.bodySmall),
          ),
          const SizedBox(height: 16),
          Text(s.aboutText, style: t.bodyLarge),
          const SizedBox(height: 20),
          Text(s.liveRates, style: t.titleSmall),
          TextButton(
            key: const Key('siteLink'),
            style: TextButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
            ),
            onPressed: () => _open(AppInfo.siteUrl),
            child: const Text(
              AppInfo.siteAnchor,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(s.privacy),
            onTap: () => _open(AppInfo.privacyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(s.source),
            subtitle: const Text(
              AppInfo.sourceUrl,
              textDirection: TextDirection.ltr,
            ),
            onTap: () => _open(AppInfo.sourceUrl),
          ),
          const SizedBox(height: 8),
          Text(s.note, style: t.bodySmall),
        ],
      ),
    );
  }
}
