# SZWebViewBridge

[![CI Status](https://img.shields.io/travis/eroscai/SZWebViewBridge.svg?style=flat)](https://travis-ci.org/eroscai/SZWebViewBridge)
[![Version](https://img.shields.io/cocoapods/v/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)
[![License](https://img.shields.io/cocoapods/l/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)
[![Platform](https://img.shields.io/cocoapods/p/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)

SZWebViewBridge is a lightweight, pure-Swift library for bridge sending messages between WKWebView and Web client. Based on message handler.

## Requirements

- iOS 10.0+
- Swift 5.0+

## Installation

SZWebViewBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SZWebViewBridge'
```

## Usage

1. Init `SZWebViewBridge` with a `WKWebView` and `UIViewController`. (The `UIViewController` will assign to handler and would be used in the future.(e.g., push or present to another `UIViewController`))

```swift
let bridge = SZWebViewBridge(webView: webView, viewController: self)
webViewBridge = bridge  // make sure bridge will not be deinit.
```
2. Add some predefined handlers.

```swift
var handlers: SZWebViewBridgeBaseHandlerObject {
    return [
        "setTitle": TitleHandler.self,
        "alert": AlertHandler.self,
        "testError": TestReceiveErrorHandler.self,
        "testSuccess": TestReceiveSuccessHandler.self,
        "testPush": TestPushHandler.self,
    ]
}
webViewBridge.addHandlers(handlers: handlers)
```

3. All Done! You can add or remove handler using with function `addHandlers` and `removeHandlers`. More detail usage please check example project.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

eroscai, csz0102@gmail.com

## License

SZWebViewBridge is available under the MIT license. See the LICENSE file for more info.
