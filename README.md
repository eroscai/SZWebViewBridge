# SZWebViewBridge

[![CI Status](https://img.shields.io/travis/eroscai/SZWebViewBridge.svg?style=flat)](https://travis-ci.org/eroscai/SZWebViewBridge)
[![Version](https://img.shields.io/cocoapods/v/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)
[![License](https://img.shields.io/cocoapods/l/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)
[![Platform](https://img.shields.io/cocoapods/p/SZWebViewBridge.svg?style=flat)](https://cocoapods.org/pods/SZWebViewBridge)

SZWebViewBridge is a lightweight, pure-Swift library for sending messages between WKWebView and Web client. Based on message handler.

## Requirements

- iOS 10.0+
- Swift 5.0+

## Installation

SZWebViewBridge is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SZWebViewBridge'
```

## Principle

1. Encapsulates the JS code and Native code for comunication, and automatically inject JS code when initializing the `Bridge` on the Native side, without any additional configuration.

Below is the sample code for sending a message on the JS side：

```js
// post message with params
function testAlert() {
    window.szBridge.post('alert', {
        'title': 'This is alert title',
        'message': 'This is alert message'
})
}

// post message with params and callback
function testReceiveSuccess() {
    window.szBridge.post('testSuccess', {
        'key1': 'value1',
        'key2': {
            'subkey1': 'subvalue2'
        }
    }, function (result, error) {
        alertUsingBridge(JSON.stringify(result))
    })
}
```
The sample code for Native side：

```swift
// post message
webViewBridge.post(action: "change", params: nil)

// callback
let response = [
    "param1": "value1",
    "param2": "value2",
]
let success: SZWebViewBridgeResult = .success(response)
webViewBridge.callback(callbackId: callbackId, result: success)
```

2. Native side need `Handler` to receive message sent by JS side. The passed parameters will be automatically parsed into the `params` variable, and other useful parameters also defined in the `Handler`. For full list of avaiable parameters, refer to `SZWebViewBridgeBaseHandler`.

Below is the sample code for receive a message and sends a callback.

```swift
import UIKit
import SZWebViewBridge

class TestReceiveSuccessHandler: SZWebViewBridgeBaseHandler {

    override func invoke() throws {
        guard let params = params else { return }

        print(params)
        if let webViewBridge = webViewBridge {
            if isValidCallbackId {
                let response = [
                    "param1": "value1",
                    "param2": "value2",
                ]
                let success: SZWebViewBridgeResult = .success(response)
                webViewBridge.callback(callbackId: callbackId, result: success)
            }
        }

    }
    
}
```

3. Because all handlers must adopt the same protocol, it can be easily get parameters and various variables needed.
4. Each handler is a separate class/file that can be easily added and removed.

## Usage

1. Init `SZWebViewBridge` with a `WKWebView` and `UIViewController`. (The `UIViewController` will assign to handler and would be used in the future.(e.g., push or present to another `UIViewController`))

```swift
let bridge = SZWebViewBridge(webView: webView, viewController: self)
webViewBridge = bridge  // make sure bridge will not be deinit.
```
2. Add some predefined handlers. For example define a `TitleHandler`

```swift
import UIKit
import SZWebViewBridge

class TitleHandler: SZWebViewBridgeBaseHandler {

    override func invoke() throws {
        guard let params = params else { return }

        if let title = params["title"] as? String {
            if let viewController = viewController {
                viewController.title = title
            }
        }
    }

}
```

Then use function `addHandlers` or `removeHandlers` to add/remove handlers.

```swift
var handlers: SZWebViewBridgeBaseHandlerObject {
    return [
        "setTitle": TitleHandler.self,
        ...
    ]
}
webViewBridge.addHandlers(handlers: handlers)
```

3. All Done!  More detail usage please check example project.


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

eroscai, csz0102@gmail.com

## License

SZWebViewBridge is available under the MIT license. See the LICENSE file for more info.
