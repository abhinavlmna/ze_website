# Logo artwork

Drop the supplied Ze Space Interior logo here as `logo.png` (transparent
background, roughly 400 px tall so it stays crisp on high-density screens).

Then:

1. Uncomment `- assets/logo/` under `assets:` in `pubspec.yaml`.
2. Set `kUseLogoAsset = true` at the top of
   `lib/widgets/common/brand_logo.dart`.

Until then the lockup is drawn in code from the logo's geometry and colours.
