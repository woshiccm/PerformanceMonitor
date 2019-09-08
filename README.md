# PerformanceMonitor

![badge-pms](https://img.shields.io/badge/languages-Swift|ObjC-orange.svg)
![badge-platforms](https://img.shields.io/cocoapods/p/RCBacktrace.svg?style=flat)
![badge-languages](https://img.shields.io/badge/supports-Carthage|CocoaPods|SwiftPM-green.svg)
[![Swift Version](https://img.shields.io/badge/Swift-4.0--5.0.x-F16D39.svg?style=flat)](https://developer.apple.com/swift)

PerformanceMonitor is a non-invasive APM system, Including monitoring CPU,Memory,FPS,Recording all OC and Swift methods time consuming,etc.

## Plugin
* CPUMonitor
* MemoryMonitor
* FPSMonitor
* FluecyMonitor
* SwiftTrace

## Features

- [x] Monitor cup usage, record current thread call stack if the usage rate exceeds 80%
- [x] Monitor memory usage
- [x] Monitor fps
- [x] Record main thread call stack if app is not fluecy
- [x] Record all OC and Swift methods time consuming  

>Note: none of these features will work on a class or method that is final or internal in a module compiled with whole module optimisation as the dispatch of the method will be "direct" i.e. linked to a symbol at the call site rather than going through the class' vtable.

![Screen Shot 2019-09-08 at 3.44.08 PM.png](https://upload-images.jianshu.io/upload_images/2086987-a4b882686eaa057f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Screen Shot 2019-09-08 at 3.44.23 PM.png](https://upload-images.jianshu.io/upload_images/2086987-e6a741cedc62c567.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![Screen Shot 2019-09-08 at 3.44.36 PM.png](https://upload-images.jianshu.io/upload_images/2086987-b51bcdc2dd41dfa1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## Usage

### setup

```
RCBacktrace.setup()
performanceMonitor = PerformanceMonitor(displayOptions: [.cpu, .memory, .fps, .fluecy])
performanceMonitor?.start()
SwiftTrace.traceBundle(containing: type(of: self))

```



≈ Requirements

- iOS 8.0+
- Swift 4.0-5.x

## Next Steps

* Use TableView to show records
* Improve SwiftTrace, support more Swift methods

## Installation

#### Carthage
Add the following line to your [Cartfile](https://github.com/carthage/carthage)

```
git "https://github.com/woshiccm/PerformanceMonitor.git" "0.0.1"
```

### CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. To integrate Aspect into your Xcode project using CocoaPods, specify it in your `Podfile`:

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target 'xxxx' do
    pod 'PerformanceMonitor', '~> 0.0.1'
end

```

##Thanks

[SwiftTrace](https://github.com/johnno1962/SwiftTrace)  
[GDPerformanceView-Swift](https://github.com/dani-gavrilov/GDPerformanceView-Swift)  
[SystemEye](https://github.com/zixun/SystemEye)  
[AppPerformance](https://github.com/SilongLi/AppPerformance)  

## License

Aspect is released under the MIT license. See LICENSE for details.
