import 'package:theme_provider/theme_provider.dart';
import './light_theme.dart';
import './dark_theme.dart';
import './oled_theme.dart';

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
