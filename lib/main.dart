import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/system_chrome.dart';
import 'presentation/app/cya_bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // The app paints under the status and navigation bars, so its background is
  // the only background (see CyaSystemChrome).
  CyaSystemChrome.goEdgeToEdge();
  runApp(const ProviderScope(child: CyaBootstrap()));
}
