import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';

/// The real launcher icon of an app a promise was shared from.
///
/// Icons are fetched once per package and held for the life of the app: a
/// promise list scrolls past the same handful of packages over and over, and
/// re-crossing the platform channel for WhatsApp's icon on every row would put
/// a channel round-trip inside a scroll (PRD §9.1).
///
/// Not `autoDispose` for the same reason — the whole point is that the second
/// row asking for `com.whatsapp` gets the bytes for free. The cache is bounded
/// by the number of distinct apps the user has ever shared from, which is
/// small, and each entry is a ~10KB PNG.
///
/// `null` means "no icon for this package": not installed, uninstalled since,
/// or a platform without launcher icons. Callers fall back to Cya!'s own
/// mascot rather than showing a gap.
final appIconProvider = FutureProvider.family<Uint8List?, String>((
  ref,
  packageName,
) async {
  if (packageName.isEmpty) return null;
  return ref.watch(reminderPortProvider).appIcon(packageName);
});
