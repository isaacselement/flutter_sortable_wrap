[![pub package](https://img.shields.io/pub/v/flutter_sortable_wrap.svg)](https://pub.dev/packages/flutter_sortable_wrap)

##### Build & Run `example/lib/main.dart` on iOS/Android/Chrome/MacOS for more demonstrations
`cd example/; flutter clean; flutter run -d macOS`


#### Simple to use

```
SortableWrap(
  children: children,
  onSorted: (int oldIndex, int newIndex) {
    setState(() {
      your_data_array.insert(newIndex, your_data_array.removeAt(oldIndex));
      print('----->>>>> your_data_array: $your_data_array');
    });
  },
  spacing: 10,
  runSpacing: 15,
)
```


### Demonstrations

<img src="https://raw.githubusercontent.com/isaacselement/flutter_sortable_wrap/master/example/resources/Kapture%202023-03-22%20at%2017.59.11.gif" width="32%">


##### Features and Issues

Please feel free to request new features and bugs at the [issue tracker][tracker]

[tracker]: https://github.com/isaacselement/flutter_sortable_wrap/issues