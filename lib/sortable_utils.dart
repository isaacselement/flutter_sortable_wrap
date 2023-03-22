/// Logs
void iDebugLog(String msg) {
  assert(() {
    print('${DateTime.now()} [Wrap] $msg');
    return true;
  }());
}

/// Extensions
extension ListEx<E> on List<E> {
  E? get firstSafe => atSafe(0);

  E? get lastSafe => atSafe(length - 1);

  E? atSafe(int index) => (isEmpty || index < 0 || index >= length) ? null : elementAt(index);

  void swap(int first, int second) {
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }
}
