import 'package:example/page/page_next.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sortable_wrap/flutter_sortable_wrap.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: App()));
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  List<int> yourDataArray = [];

  @override
  void initState() {
    super.initState();

    yourDataArray.clear();
    for (int i = 0; i < 21; i++) {
      yourDataArray.add(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    iDebugLog('App rebuild!!!!');
    Color alphaColor(Color color, {int alpha = 128}) => color.withAlpha(alpha);
    List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.purpleAccent,
    ];
    colors = colors.map((e) => alphaColor(e)).toList();
    Widget boxText(String text) => SizedBox(width: 72, height: 72, child: Center(child: Text(text)));
    List<Widget> children = [
      for (int i = 0; i < yourDataArray.length; i++)
        ColoredBox(color: colors[yourDataArray[i] % colors.length], child: boxText('${yourDataArray[i]}'))
    ];

    SortableWrapOptions options = SortableWrapOptions();
    // options.isLongPressDraggable = true;
    options.draggableFeedbackBuilder = (Widget child) {
      return Material(
        elevation: 18.0,
        child: Card(child: child),
        shadowColor: Colors.grey,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
      );
    };

    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.topCenter,
          color: Colors.white.withAlpha(64),
          child: SortableWrap(
            children: children,
            onSorted: (int oldIndex, int newIndex) {
              setState(() {
                yourDataArray.insert(newIndex, yourDataArray.removeAt(oldIndex));
                iDebugLog('Data sorted after >>>>>: $yourDataArray');
              });
            },
            onSortStart: (int index) {
              iDebugLog('Data sorted before >>>>>: $yourDataArray');
            },
            spacing: 10,
            runSpacing: 15,
            options: options,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).push(
            PageRouteBuilder(
              pageBuilder: (ctx, one, two) => const PageNext(),
              transitionsBuilder: (ctx, one, two, child) => SlideTransition(
                position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)).animate(one),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
