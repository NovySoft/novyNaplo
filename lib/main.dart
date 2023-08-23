import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:novynaplo_v2/helpers/UI/theme/theme_helper.dart';
import 'package:theme_provider/theme_provider.dart';

void main() {
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
        print("Saved theme: $savedTheme");

        if (savedTheme != null) {
          controller.setTheme(savedTheme);
        } else {
          Brightness? platformBrightness =
              SchedulerBinding.instance.platformDispatcher.platformBrightness;
          print("Platform brightness: $platformBrightness");
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
            theme: ThemeProvider.themeOf(themeContext).data,
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

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
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
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
