import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:noticewatch/models/app_release_model.dart';

/// Reusable update dialog widget.
class UpdateDialog extends StatelessWidget {
  final String versionName;
  final String changelog;
  final String apkUrl;
  final bool forceUpdate;

  const UpdateDialog({
    Key? key,
    required this.versionName,
    required this.changelog,
    required this.apkUrl,
    required this.forceUpdate,
  }) : super(key: key);

  Future<void> _openUrl(BuildContext context) async {
    final uri = Uri.tryParse(apkUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid update URL')));
      return;
    }

    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open update URL')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to open update URL: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardTheme.color ?? const Color(0xFF1E293B);
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      backgroundColor: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Material(
            color: cardColor,
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.system_update_rounded, color: primary, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('New Update Available', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('Latest: $versionName', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (changelog.isNotEmpty) ...[
                    Text('What’s new', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 220),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        child: Text(changelog, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ] else ...[
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!forceUpdate)
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface),
                          child: const Text('Later'),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _openUrl(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text('Update Now', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to show the update dialog for an [AppRelease].
Future<void> showUpdateDialog(BuildContext context, AppRelease release) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: !release.forceUpdate,
    builder: (ctx) => WillPopScope(
      onWillPop: () async => !release.forceUpdate,
      child: UpdateDialog(
        versionName: release.versionName,
        changelog: release.changeLog,
        apkUrl: release.apkUrl,
        forceUpdate: release.forceUpdate,
      ),
    ),
  );
}
