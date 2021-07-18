---
title: Flutter插件开发-电池电量管理插件示例
description:
toc: true
authors: 
  - kangshaojun
date: '2021-05-31'
lastmod: '2021-05-31'
---

Flutter插件开发-电池电量管理插件示例.

<!--more-->


以下说明了怎么调用平台特定的接口来取得并显示当前的电池电量。通过单独的一个的平台消息，使用 Android `BatteryManager` 接口，和 iOS `device.batteryLevel` 接口。

*注意*：这个示例完整可运行的代码在这儿[`/examples/platform_channel/`](https://github.com/flutter/flutter/tree/master/examples/platform_channel)，该版本使用 Java  开发 Android，Objective-C 开发的 iOS。iOS 的 Swift 版本请参阅[`/examples/platform_channel_swift/`](https://github.com/flutter/flutter/tree/master/examples/platform_channel_swift).

## 步骤 1: 创建新工程 

开始创建新工程：

* 在终端运行: `flutter create batterylevel`

默认模板支持使用 Java 编写 Android，Objective-C 编写 iOS。想使用Kotlin 或者 Swift，使用 `-i` 与/或 `-a` 标记；

* 终端运行： `flutter create -i swift -a kotlin batterylevel`

## 步骤 2: 创建 Flutter 平台客户端 

应用的 `State` 类持有当前应用的状态。我们需要扩展它来持有当前的电池状态。

首先，我们构造通道。我们使用 `MethodChannel` 编写单独的平台方法并返回电池变量。

通道的客户端和宿主端通过在构造器中传入通道名来连接。所有的通道名在一个应用中必须唯一；我们推荐使用唯一的'域名前缀'给通道名加前缀，如 `samples.flutter.io/battery`。

<!-- skip -->
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
...
class _MyHomePageState extends State<MyHomePage> {
  static const platform = const MethodChannel('samples.flutter.io/battery');

  // Get battery level.
}
```

接下来，我们调用方法通道上的方法，指定具体方法。通过字符串标识符 `getBatteryLevel` 调用。调用也许会失败 -- 例如如果平台不支持平台接口（比如运行在模拟器上），所以我们用语句块来包装`invokeMethod` 调用。我们拿到返回结果在 `setState` 里面用 `_batteryLevel` 更新用户界面状态。

<!-- skip -->
```dart
  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }
```

最后，我们把模板中的 `build` 方法替换为一个小的用户界面用字符串显示电池状态，还有一个按钮来刷新这个值。

<!-- skip -->
```dart
@override
Widget build(BuildContext context) {
  return new Material(
    child: new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new RaisedButton(
            child: new Text('Get Battery Level'),
            onPressed: _getBatteryLevel,
          ),
          new Text(_batteryLevel),
        ],
      ),
    ),
  );
}
```


## 步骤 3a: 用 Java 添加 Android 平台特定实现 

*注意*: 以下步骤使用 Java。如果你更喜欢 Kotlin，跳到步骤3b。

在 Android Studio 中打开 Android 宿主端：

1. 打开 Android Studio。

1. 选择菜单项 '文件 > 打开...'。

1. 导航到 Flutter 应用程序的目录，选择它里面的 `android` 文件夹。点击确定。

1. 在工程视图下打开位于 `java` 文件夹的 `MainActivity.java` 文件。

下一步，创建 `MethodChannel` 并在 `onCreate` 方法中设置 `MethodCallHandler`。确保使用了和 Flutter 客户端同样的通道名。

```java
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.io/battery";

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        // TODO
                    }
                });
    }
}
```

下一步，我们添加真正的 Android Java 代码，使用 Android 电池接口取到电池电量。这些代码和你编写原生的 Android 应用一样。

首先，在文件顶部添加必要的应用：

```
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;
```

在 activity 类中 `onCreate` 的方法下面紧接着添加一个新的方法：

```java
private int getBatteryLevel() {
  int batteryLevel = -1;
  if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
    BatteryManager batteryManager = (BatteryManager) getSystemService(BATTERY_SERVICE);
    batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY);
  } else {
    Intent intent = new ContextWrapper(getApplicationContext()).
        registerReceiver(null, new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
    batteryLevel = (intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100) /
        intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1);
  }

  return batteryLevel;
}
```

最后，我们完成之前添加的 `onMethodCall` 方法。我们需要一个单一的平台方法，`getBatteryLevel`，我们在 `call` 参数中检测它。这个平台方法的实现调用了我们在之前步骤中写的 Android 代码，并在成功和错误的情况下都返回 `response` 参数。如果调用了一个未知的方法，我们会发出报告。替换：

```java
public void onMethodCall(MethodCall call, Result result) {
    // TODO
}
```

为：

```java
@Override
public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("getBatteryLevel")) {
        int batteryLevel = getBatteryLevel();

        if (batteryLevel != -1) {
            result.success(batteryLevel);
        } else {
            result.error("UNAVAILABLE", "Battery level not available.", null);
        }
    } else {
        result.notImplemented();
    }
}               
```

你现在应该能够在 Android 系统上运行应用程序了。如果使用了 Android 模拟器，你可以在点击工具栏中的 `...` 按钮，在扩展控制栏设置电池电量。

## 步骤 3b: 用 Kotlin 添加 Android 特定平台实现 

*注意*：以下步骤和步骤 3a 类似，除了用 Kotlin 代替 Java。

本步骤假设你在[步骤 1.](#example-project)中使用 `-a kotlin` 选项创建工程。

在 Android Studio 中打开 Android 宿主端：

1. 打开 Android Studio。

1. 选择菜单项 '文件 > 打开...'。

1. 导航到 Flutter 应用程序的目录，选择它里面的 `android` 文件夹。点击确定。

1. 在工程视图下打开位于 `kotlin` 文件夹下的 `MainActivity.kt` 文件。(注意：如果你正在使用 Android Studio 2.3 编辑，'kotlin' 文件夹将会显示名为 ’java'。）

下一步，创建 `MethodChannel` 并在 `onCreate` 方法中调用 `setMethodCallHandler `。确保使用了和 Flutter 客户端同样的通道名。

```kotlin
import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity() : FlutterActivity() {
  private val CHANNEL = "samples.flutter.io/battery"

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)

    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      // TODO
    }
  }
}
```

下一步，我们添加真正的 Android Kotlin 代码，使用 Android 电池接口取到电池电量。这些代码和你编写原生的 Android 应用一样。

首先，在文件顶部添加必要的引用：

```
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
```

在 `MainActivity` 类中 `onCreate` 的方法下面紧接着添加一个新的方法：

```kotlin
  private fun getBatteryLevel(): Int {
    val batteryLevel: Int
    if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
      val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    } else {
      val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
      batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
    }

    return batteryLevel
  }
```

最后，我们完成之前添加的 `onMethodCall` 方法。我们需要一个单一的平台方法，`getBatteryLevel`，我们在 `call` 参数中检测它。这个平台方法的实现调用了我们在之前步骤中写的 Android 代码，并在成功和错误的情况下都返回 `response` 参数。如果调用了一个未知的方法，我们会发出报告。替换：

```kotlin
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      // TODO
    }
```

为:

```kotlin
    MethodChannel(flutterView, CHANNEL).setMethodCallHandler { call, result ->
      if (call.method == "getBatteryLevel") {
        val batteryLevel = getBatteryLevel()

        if (batteryLevel != -1) {
          result.success(batteryLevel)
        } else {
          result.error("UNAVAILABLE", "Battery level not available.", null)
        }
      } else {
        result.notImplemented()
      }
    }
```

你现在应该能够在 Android 系统上运行应用程序了。如果使用了 Android 模拟器，你可以在点击工具栏中的 `...` 按钮，在扩展控制栏设置电池电量。

## 步骤 4a: 用 Objective-C 添加 iOS 平台特定实现 

*注意*：以下步骤使用 Objective-C。如果你更喜欢 Swift，跳到步骤4b。

在 Xcode 中打开 Flutter 应用的 iOS 宿主端：

1. 打开 Xcode

1. 选择菜单项 '文件 > 打开...'

1. 导航到 Flutter 应用程序的目录，选择它里面的 `ios` 文件夹。点击确定。

1. 确保 Xcode 工程编译没有错误。

1. 打开位于 Runner > Runner 工程目录下的文件 `AppDelegate.m`。

下一步，创建 'FlutterMethodChannel' 并在 `application
didFinishLaunchingWithOptions:` 方法中添加一个处理器。确保使用了和 Flutter 客户端同样的通道名。

```objectivec
#import <Flutter/Flutter.h>

@implementation AppDelegate
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
  FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;

  FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                          methodChannelWithName:@"samples.flutter.io/battery"
                                          binaryMessenger:controller];

  [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
    // TODO
  }];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

下一步，我们添加真正的 iOS ObjectiveC 代码，使用 iOS 电池接口取到电池电量。这些代码和你编写原生的 iOS 应用一样。

在 `AppDelegate` 类中，`@end` 之前接着添加一个新方法：

```objectivec
- (int)getBatteryLevel {
  UIDevice* device = UIDevice.currentDevice;
  device.batteryMonitoringEnabled = YES;
  if (device.batteryState == UIDeviceBatteryStateUnknown) {
    return -1;
  } else {
    return (int)(device.batteryLevel * 100);
  }
}
```

最后，我们完成之前添加的 `setMethodCallHandler` 方法。我们需要一个单一的平台方法，`getBatteryLevel`，我们在 `call` 参数中检测它。这个平台方法的实现调用了我们在之前步骤中写的 iOS 代码，并在成功和错误的情况下都返回 `response` 参数。如果调用了一个未知的方法，我们会发出报告。

```objectivec
[batteryChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
  if ([@"getBatteryLevel" isEqualToString:call.method]) {
    int batteryLevel = [self getBatteryLevel];

    if (batteryLevel == -1) {
      result([FlutterError errorWithCode:@"UNAVAILABLE"
                                 message:@"Battery info unavailable"
                                 details:nil]);
    } else {
      result(@(batteryLevel));
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}];
```

你现在应该能够在 iOS 系统上运行应用程序了。如果使用了 iOS 模拟器，注意它不支持电池相关接口，应用会显示 '无法获取电池信息'。

## 步骤 4b: 用 Swift 添加 iOS 平台特定实现 

*注意*：以下步骤和步骤 3a 类似，除了用 Swift 代替 Objective-C。

本步骤假设你在[步骤 1.](#example-project)中使用 `-i swift` 选项创建工程。

在 Xcode 中打开 Flutter 应用的 iOS 宿主端：

1. 打开 Xcode

1. 选择菜单项 '文件 > 打开...'

1. 导航到 Flutter 应用程序的目录，选择它里面的 `ios` 文件夹。点击确定。

下一步，在使用 Objective-C 设置的标准模板中添加 Swift 支持：

1. 在工程中展开 Runner > Runner。

1. 在工程中打开位于 Runner > Runner 下的`AppDelegate.swift`。

下一步，重写 `application` 函数并创建一个 `FlutterMethodChannel` 绑定到通道 `samples.flutter.io/battery`：

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GeneratedPluginRegistrant.register(with: self);

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let batteryChannel = FlutterMethodChannel.init(name: "samples.flutter.io/battery",
                                                   binaryMessenger: controller);
    batteryChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
      // Handle battery messages.
    });

    return super.application(application, didFinishLaunchingWithOptions: launchOptions);
  }
}
```

下一步, 我们添加真正的 iOS Swift 代码，使用 iOS 电池接口取到电池电量。这些代码和你编写原生的 iOS 应用一样。

在 `AppDelegate.swift` 底部添加下面的新方法：

```swift
private func receiveBatteryLevel(result: FlutterResult) {
  let device = UIDevice.current;
  device.isBatteryMonitoringEnabled = true;
  if (device.batteryState == UIDeviceBatteryState.unknown) {
    result(FlutterError.init(code: "UNAVAILABLE",
                             message: "Battery info unavailable",
                             details: nil));
  } else {
    result(Int(device.batteryLevel * 100));
  }
}
```

最后，我们完成之前添加的 `setMethodCallHandler` 方法。我们需要一个单一的平台方法，`getBatteryLevel`，我们在 `call` 参数中检测它。这个平台方法的实现调用了我们在之前步骤中写的 iOS 代码，并在成功和错误的情况下都返回 `response` 参数。如果调用了一个未知的方法，我们会发出报告。

```swift
batteryChannel.setMethodCallHandler({
  (call: FlutterMethodCall, result: FlutterResult) -> Void in
  if ("getBatteryLevel" == call.method) {
    receiveBatteryLevel(result: result);
  } else {
    result(FlutterMethodNotImplemented);
  }
});
```

你现在应该能够在 iOS 系统上运行应用程序了。如果使用了 iOS 模拟器，注意它不支持电池相关接口，应用会显示 '无法获取电池信息'。

## Flutter课程
[https://www.kangshaojun.com](https://www.kangshaojun.com)
