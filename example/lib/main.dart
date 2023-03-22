import 'package:flutter/material.dart';
import 'package:flutter_sortable_wrap/flutter_sortable_wrap.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  List<int> array = [];

  @override
  void initState() {
    super.initState();

    array.clear();
    for (int i = 0; i < 21; i++) array.add(i);
  }

  @override
  Widget build(BuildContext context) {
    iDebugLog('App rebuild!!!!');
    Color alphaColor(Color color, {int alpha = 64}) => color.withAlpha(alpha);
    Widget boxText(String text) => SizedBox(width: 72, height: 72, child: Center(child: Text(text)));
    List<Color> colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.pinkAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.purpleAccent,
    ];
    colors = colors.map((e) => alphaColor(e)).toList();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Container(
            alignment: Alignment.topCenter,
            color: Colors.white.withAlpha(64),
            child: SortableWrap(
              children: [
                for (int i = 0; i < array.length; i++) ColoredBox(color: colors[array[i] % colors.length], child: boxText('${array[i]}')),
              ],
              onSorted: (int oldIndex, int newIndex) {
                setState(() {
                  array.insert(newIndex, array.removeAt(oldIndex));
                  iDebugLog('=======>>>>> array: $array');
                });
              },
              spacing: 10,
              runSpacing: 15,
            ),
          ),
        ),
      ),
    );
  }
}
