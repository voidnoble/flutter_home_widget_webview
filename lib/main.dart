import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:home_widget/home_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HomeWidget.registerBackgroundCallback(backgroundCallback);

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MyApp());
}

// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? uri) async {
  if (uri == null) return;

  if (uri.host == 'updatecounter') {
    int _counter = 0;
    await HomeWidget.getWidgetData('_counter', defaultValue: 0).then((value) {
      _counter = value!;
      _counter++;
    });
    await HomeWidget.saveWidgetData('_counter', _counter);
    await HomeWidget.updateWidget(
        name: 'AppWidgetProvider', androidName: 'AppWidgetProvider');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _menuId = 0;
  InAppWebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    HomeWidget.widgetClicked.listen((uri) => loadData(uri));
  }

  void loadData(Uri? uri) async {
    await HomeWidget.getWidgetData('_counter', defaultValue: 0).then((value) {
      _counter = value!;
    });
    setState(() {});

    if (uri == null) return;

    if (uri.host == 'click.menu') {
      var uriPaths = uri.pathSegments;
      _menuId = int.parse(uriPaths[0]);
      await HomeWidget.saveWidgetData('_menuId', _menuId);

      // 방법1. 웹뷰 JS 실행
      webViewController?.evaluateJavascript(
          source: "document.querySelector('.menu-$_menuId').click();");

      // 방법2. 웹뷰 URL 이동
      // webViewController?.loadUrl(urlRequest: URLRequest(url: Uri.parse(uri.toString())));
    }
    setState(() {});
  }

  Future<void> updateAppWidget() async {
    await HomeWidget.saveWidgetData<int>('_counter', _counter);
    await HomeWidget.updateWidget(
        name: 'AppWidgetProvider', iOSName: 'AppWidgetProvider');
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      android: AndroidInAppWebViewOptions(useHybridComposition: true));

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SafeArea(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
                child: InAppWebView(
              initialData: InAppWebViewInitialData(data: """
<!DOCTYPE html>
<html lang="ko">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
    </head>
    <body>
        <h1>JavaScript Handlers</h1>
        <a class="menu-1" href="javascript:alert('menu1 clicked')">Menu 1</a>
        <a class="menu-2" href="javascript:alert('menu2 clicked')">Menu 2</a>
        <a class="menu-3" href="javascript:alert('menu3 clicked')">Menu 3</a>
        <script>
            window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
                window.flutter_inappwebview.callHandler('handlerMenu')
                  .then(function(data) {
                    // Flutter로부터 받기
                    console.log(JSON.stringify(data));

                    // 웹페이지 메뉴를 클릭
                    document.querySelector('.menu-'+ data.id).click();
                    
                    // Flutter로 보내기
                    window.flutter_inappwebview
                      .callHandler('handlerMenuWithArgs', data.id, true, ['bar', 5], {foo: 'baz'}, result);
                });
            });
        </script>
    </body>
</html>
"""),
              initialOptions: options,
              onWebViewCreated: (controller) {
                setState(() {
                  webViewController = controller;
                });

                // 웹뷰로 보내기
                controller.addJavaScriptHandler(
                    handlerName: 'handlerMenu',
                    callback: (args) {
                      // return data to the JavaScript side!
                      return {
                        'id': _menuId,
                        'msg': 'Trigger 메뉴$_menuId 클릭 from Flutter'
                      };
                    });

                // 웹뷰로부터 받기
                controller.addJavaScriptHandler(
                    handlerName: 'handlerMenuWithArgs',
                    callback: (args) {
                      if (kDebugMode) {
                        print(args);
                      }
                      // it will print: [1, true, [bar, 5], {foo: baz}, {bar: bar_value, baz: baz_value}]
                    });
              },
              onConsoleMessage: (controller, consoleMessage) {
                if (kDebugMode) {
                  print(consoleMessage);
                }
                // it will print: {message: {"bar":"bar_value","baz":"baz_value"}, messageLevel: 1}
              },
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
