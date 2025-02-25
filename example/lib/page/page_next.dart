import 'package:flutter/material.dart';
import 'package:flutter_sortable_wrap/flutter_sortable_wrap.dart';

class PageNext extends StatefulWidget {
  const PageNext({Key? key}) : super(key: key);

  @override
  PageNextState createState() => PageNextState();
}

class PageNextState extends State<PageNext> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Container(
            alignment: Alignment.topCenter,
            child: CustomScrollView(
              cacheExtent: 0,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  floating: true,
                  delegate: MyDelegate(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ));
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate();

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    Widget boxText(String text) => SizedBox(width: 72, height: 72, child: Center(child: Text(text)));

    return SortableWrap(
      onSorted: (int oldIndex, int newIndex) {
        iDebugLog('####### oldIndex: $oldIndex, newIndex: $newIndex');
      },
      children: List.generate(
        10,
        (index) => Padding(
          padding: const EdgeInsets.all(2),
          child: ColoredBox(color: Colors.grey, child: boxText('$index')),
        ),
      ).toList(),
    );
  }

  @override
  double get maxExtent {
    return 200;
  }

  @override
  double get minExtent {
    return 200;
  }

  @override
  bool shouldRebuild(covariant MyDelegate oldDelegate) {
    return false;
  }
}
