//
//  SZWebViewBridgeInvoker.swift
//  SZWebViewBridge
//
//  Created by CaiSanze on 2019/10/12.
//

import UIKit

struct SZWebViewBridgeHandlers {

    private var handlers: SZWebViewBridgeBaseHandlerObject = [:]
    private let normalLock = NSLock()

    func handlerForAction(action: String) -> SZWebViewBridgeBaseHandler? {
        normalLock.lock()
        defer { normalLock.unlock() }

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
        normalLock.lock()
        defer { normalLock.unlock() }

        guard handlers[action] != nil else {
            return false
        }

        return true
    }

    mutating func addHandlers(handlers: SZWebViewBridgeBaseHandlerObject) {
        normalLock.lock()
        defer { normalLock.unlock() }

        self.handlers.merge(handlers) { $1 }
    }

    mutating func removeHandlers(handlerActions: Array<String>) {
        normalLock.lock()
        defer { normalLock.unlock() }

        for action in handlerActions {
            self.handlers.removeValue(forKey: action)
        }
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
        allHandlers.addHandlers(handlers: handlers)
    }

    func removeHandlers(handlerActions: Array<String>) {
        allHandlers.removeHandlers(handlerActions: handlerActions)
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
