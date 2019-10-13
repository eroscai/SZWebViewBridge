//
//  SZWebViewBridge.swift
//  SZWebViewBridge
//
//  Created by CaiSanze on 2019/10/12.
//

import UIKit
import WebKit

public class SZWebViewBridge: NSObject {
    static let name: String = "szBridge"

    fileprivate static let callbackEventName = "SZDidReceiveNativeCallback"
    fileprivate static let postEventName = "SZDidReceiveNativeBroadcast"

    fileprivate let config: WKWebViewConfiguration
    fileprivate weak var webView: WKWebView?
    fileprivate weak var viewController: UIViewController?
    fileprivate lazy var webViewBridgeInvoker: SZWebViewBridgeInvoker = createWebViewBridgeInvoker()

    fileprivate enum MessageKey {
        static let action = "action"
        static let params = "params"
        static let callback = "callback"
    }

    deinit {
        config.removeObserver(self, forKeyPath: #keyPath(WKWebViewConfiguration.userContentController))
        config.userContentController.removeScriptMessageHandler(forName: SZWebViewBridge.name)
    }

    /// Bridge initialize function.
    /// - Parameter webView: Current using webview.
    /// - Parameter viewController: The `UIViewController` contains current webview, will assign to handler and would be used in the future.(e.g., push or present to another `UIViewController`)
    public init(webView: WKWebView, viewController: UIViewController?) {
        self.webView = webView
        self.viewController = viewController
        self.config = webView.configuration
        super.init()

        let className = String(describing: SZWebViewBridge.self)
        if let bundlePath = Bundle(for: SZWebViewBridge.self).path(forResource: className, ofType: "bundle"),
            let bridgeBundle = Bundle(path: bundlePath),
            let scriptPath = bridgeBundle.path(forResource: "sz_bridge", ofType: "js"),
            let scriptSource = try? String(contentsOfFile: scriptPath)
        {
            let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            config.userContentController.addUserScript(userScript)
        }

        config.addObserver(self, forKeyPath: #keyPath(WKWebViewConfiguration.userContentController), options: [.new, .old], context: nil)
        config.userContentController.add(self, name: SZWebViewBridge.name)
    }

    /// Manually remove bridge
    public func removeBridge() {
        config.userContentController.removeScriptMessageHandler(forName: SZWebViewBridge.name)
    }

    /// Add bridge handler.
    /// - Parameter handlers: `SZWebViewBridgeBaseHandlerObject` is a dictionary. The key is action name, the value is handler. All handler must inherit from `SZWebViewBridgeBaseHandler`.
    public func addHandlers(handlers: SZWebViewBridgeBaseHandlerObject) {
        webViewBridgeInvoker.addHandlers(handlers: handlers)
    }

    /// Post message to web client.
    /// - Parameter action: The action name.
    /// - Parameter params: The params.
    /// - Parameter completion: The callback will be sent from web client.
    public func post(action: String,
                     params: [String: Any]?,
                     completion: ((Any?, Error?) -> Void)? = nil) {
        guard let webView = webView else { return }
        webView.dispatchBridgeEvent(SZWebViewBridge.postEventName,
                                    params: ["name": action],
                                    result: .success(params),
                                    completionHandler: completion)
    }

    /// Post callback to web client.
    /// - Parameter callbackId: The callbackId created by web client.
    /// - Parameter result: The `Success` or `Failed` object sent to the web client.
    public func callback(callbackId: SZWebViewBridgeCallbackId,
                         result: SZWebViewBridgeResult) {
        guard let webView = webView else { return }
        webView.dispatchBridgeEvent(SZWebViewBridge.callbackEventName,
                                    params: ["id": callbackId],
                                    result: result,
                                    completionHandler: nil)
    }

    /// Execute javaScriptString in webView
    /// - Parameter javaScriptString: The javaScriptString.
    /// - Parameter completion: The callback will be sent from web client.
    public func evaluate(_ javaScriptString: String,
                         completion: ((Any?, Error?) -> Void)? = nil) {
        guard let webView = webView else { return }
        webView.evaluateJavaScript(javaScriptString,
                                   completionHandler: completion)
    }

}

// MARK: - Observer

extension SZWebViewBridge {

    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let object = object as? WKWebViewConfiguration, object == config else {
            return
        }

        guard let keyPath = keyPath, keyPath == #keyPath(WKWebViewConfiguration.userContentController) else {
            return
        }

        guard let change = change else {
            return
        }

        if let oldContentController = change[.oldKey] as? WKUserContentController {
            oldContentController.removeScriptMessageHandler(forName: SZWebViewBridge.name)
        }

        if let newContentController = change[.newKey] as? WKUserContentController {
            newContentController.add(self, name: SZWebViewBridge.name)
        }
    }

}

// MARK: - WKScriptMessageHandler

extension SZWebViewBridge: WKScriptMessageHandler {

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard
            let body = message.body as? [String: Any],
            let action = body[MessageKey.action] as? String else {
                return
        }

        guard webViewBridgeInvoker.isHandlerRegistered(action: action) else {
            print("jsBridge method '\(action)' not registered")
            return
        }

        let params = body[MessageKey.params] as? [String: Any] ?? [:]
        let callbackId = body[MessageKey.callback] as? SZWebViewBridgeCallbackId ?? -1
        webViewBridgeInvoker.invoke(viewController: self.viewController ?? nil,
                                    action: action,
                                    params: params,
                                    callbackId: callbackId)
    }

}

// MARK: - WKWebView Extension

fileprivate extension WKWebView {

    func dispatchBridgeEvent(_ eventName: String,
                             params: [String: Any],
                             result: SZWebViewBridgeResult,
                             completionHandler: ((Any?, Error?) -> Void)? = nil) {
        var jsStr: String
        var eventDetail = params
        switch result {
        case .success(let callbackParams):
            eventDetail["params"] = callbackParams ?? [:]
            jsStr = "(function() { var event = new CustomEvent('\(eventName)', {'detail': {'params': {}}}); document.dispatchEvent(event)}());"
        case .failure(let error):
            eventDetail["error"] = ["code": error.code,
                                    "description": error.description]
            jsStr = "(function() { var event = new CustomEvent('\(eventName)', {'detail': {'error': {'code': \(error.code), 'description': '\(error.description)'}}}); document.dispatchEvent(event)}());"
        }

        let eventBody: [String: Any] = ["detail": eventDetail]
        if let enventBodyData = try? JSONSerialization.data(withJSONObject: eventBody, options: JSONSerialization.WritingOptions()),
            let eventString = String(data: enventBodyData, encoding: .utf8) {
            jsStr = "(function() { var event = new CustomEvent('\(eventName)', \(eventString)); document.dispatchEvent(event)}());"
        }

        evaluateJavaScript(jsStr, completionHandler: completionHandler)
    }
}

// MARK: - Getter

extension SZWebViewBridge {

    private func createWebViewBridgeInvoker() -> SZWebViewBridgeInvoker {
        let invoker = SZWebViewBridgeInvoker(webViewBridge: self)

        return invoker
    }

}
