import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'constants/app_colors.dart';
import 'constants/app_text.dart';
import 'constants/contact_config.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const ZeSpaceApp());
}

class ZeSpaceApp extends StatelessWidget {
  const ZeSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${ContactConfig.companyNameTitle} — ${ContactConfig.tagline}',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _SiteScrollBehavior(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: AppText.sans,
        scaffoldBackgroundColor: AppColors.canvas,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          primary: AppColors.teal,
          surface: AppColors.canvas,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.teal,
          selectionColor: AppColors.tealWash,
          selectionHandleColor: AppColors.teal,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: const Color(0x00000000),
      ),
      home: const HomePage(),
    );
  }
}

/// Lets the page be dragged with a mouse as well as scrolled, and keeps the
/// overlay scrollbar out of the composition.
class _SiteScrollBehavior extends MaterialScrollBehavior {
  const _SiteScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };

      

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;


}
