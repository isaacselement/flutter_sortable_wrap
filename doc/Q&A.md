
### If you got some error like below when you switching the different version of FlutterSdk, just `flutter clean`.

````

ld: warning: Could not find or use auto-linked framework 'FlutterMacOS'
Undefined symbols for architecture x86_64:
  "_OBJC_CLASS_$_FlutterAppDelegate", referenced from:
      _$s7example11AppDelegateCN in AppDelegate.o
  "_OBJC_CLASS_$_FlutterViewController", referenced from:
      objc-class-ref in MainFlutterWindow.o
  "_OBJC_METACLASS_$_FlutterAppDelegate", referenced from:
      _OBJC_METACLASS_$__TtC7example11AppDelegate in AppDelegate.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)

````

