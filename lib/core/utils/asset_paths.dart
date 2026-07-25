/// Centralized paths to bundled assets — keep every asset reference here
/// instead of hardcoding path strings at call sites, so a renamed/moved
/// file only needs to be updated in one place.
///
/// See the `assets:` section in `pubspec.yaml` for how these directories
/// are declared to the bundler.
class AssetPaths {
  AssetPaths._();

  static const String _icons = 'assets/icons';

  static const String sunIcon = '$_icons/sun.svg';
}
