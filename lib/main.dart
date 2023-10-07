import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:novynaplo_v2/UI/screens/welcome_screen.dart';
import 'package:novynaplo_v2/helpers/UI/theme/theme_helper.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:novynaplo_v2/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await globals.setGlobals();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      saveThemesOnChange: true,
      loadThemeOnInit: false,
      themes: [
        ThemeHelper.lightTheme,
        ThemeHelper.darkTheme,
        ThemeHelper.oledTheme,
      ],
      onInitCallback: (controller, previouslySavedThemeFuture) async {
        String? savedTheme = await previouslySavedThemeFuture;
        globals.logger.d('Saved theme read from memory: $savedTheme');

        if (savedTheme != null) {
          controller.setTheme(savedTheme);
        } else {
          Brightness? platformBrightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          globals.logger.d('Initial platform brightness: $platformBrightness');
          if (platformBrightness == Brightness.dark) {
            controller.setTheme('dark');
          } else {
            controller.setTheme('light');
          }
        }
      },
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) => MaterialApp(
            title: 'NovyNapló V2',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeProvider.themeOf(themeContext).data,
            //TODO: Locale wrapper
            home: (globals.prefs.getBool('isNew') ?? true)
                ? const WelcomeScreen()
                : const MyHomePage(),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Demo"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context)!.helloWorld,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
