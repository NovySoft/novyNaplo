import 'package:theme_provider/theme_provider.dart';
import 'package:novynaplo_v2/helpers/UI/theme/light_theme.dart';
import 'package:novynaplo_v2/helpers/UI/theme/dark_theme.dart';
import 'package:novynaplo_v2/helpers/UI/theme/oled_theme.dart';

class ThemeHelper {
  static final AppTheme lightTheme = AppTheme(
    id: 'light',
    description: 'Light Theme',
    data: lightThemeData,
  );

  static final AppTheme darkTheme = AppTheme(
    id: 'dark',
    description: 'Dark Theme',
    data: darkThemeData,
  );

  static final AppTheme oledTheme = AppTheme(
    id: 'oled',
    description: 'OLED Theme',
    data: oledThemeData,
  );
}
