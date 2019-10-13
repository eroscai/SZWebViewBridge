//
//  SZWebViewBridgeInvoker.swift
//  SZWebViewBridge
//
//  Created by CaiSanze on 2019/10/12.
//

import UIKit

struct SZWebViewBridgeHandlers {

    private var handlers: SZWebViewBridgeBaseHandlerObject = [:]

    func handlerForAction(action: String) -> SZWebViewBridgeBaseHandler? {
        guard action.count > 0 else {
            print("js bridge action name is empty")
            return nil
        }

        guard let handlerType = handlers[action] else {
            print("js bridge for action \(action) not exists")
            return nil
        }

        let handler = handlerType.init()
        return handler
    }

    public func isContainsAction(action: String) -> Bool {
        guard handlers[action] != nil else {
            return false
        }

        return true
    }

    mutating func addHandlers(handlers: SZWebViewBridgeBaseHandlerObject) {
        self.handlers.merge(handlers) { $1 }
    }

}

class SZWebViewBridgeInvoker: NSObject {

    private weak var webViewBridge: SZWebViewBridge?
    private var allHandlers = SZWebViewBridgeHandlers()

    init(webViewBridge: SZWebViewBridge) {
        self.webViewBridge = webViewBridge
        super.init()
    }

    func addHandlers(handlers: SZWebViewBridgeBaseHandlerObject) {
        allHandlers.addHandlers(handlers: handlers);
    }

    func invoke(viewController: UIViewController?,
                action: String,
                params: [String: Any],
                callbackId: SZWebViewBridgeCallbackId)
    {
        guard let handler = allHandlers.handlerForAction(action: action) else { return }

        handler.viewController = viewController
        handler.webViewBridge = webViewBridge
        handler.action = action
        handler.params = params
        handler.callbackId = callbackId

        invokeJSHandler(handler: handler)
    }

    func invokeJSHandler(handler: SZWebViewBridgeBaseHandler) {
        do {
            try handler.invoke()
        } catch {
            print(String(format: "js call %@ params %@ error %@", handler.action ?? "", handler.params ?? "", error as CVarArg))
        }
    }

    func isHandlerRegistered(action: String) -> Bool {
        return allHandlers.isContainsAction(action: action)
    }

}
