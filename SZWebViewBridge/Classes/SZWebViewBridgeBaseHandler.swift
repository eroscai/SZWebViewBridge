//
//  SZWebViewBridgeBaseHandler.swift
//  SZWebViewBridge
//
//  Created by CaiSanze on 2019/10/12.
//

import UIKit

public protocol SZWebViewBridgeHandlerProtocol {
    func invoke() throws -> Void
}

public struct SZWebViewBridgeError {
    public let code: Int
    public let description: String

    public init(code: Int, description: String) {
        self.code = code
        self.description = description
    }
}

public enum SZWebViewBridgeResult {
    case success([String: Any]?)
    case failure(SZWebViewBridgeError)
}

public typealias SZWebViewBridgeCallback = (_ result: SZWebViewBridgeResult) -> Void
public typealias SZWebViewBridgeCallbackId = Int
public typealias SZWebViewBridgeBaseHandlerObject = Dictionary<String, SZWebViewBridgeBaseHandler.Type>

/// All custom hander must inherit from this class, and should be override `invoke` function.
open class SZWebViewBridgeBaseHandler: NSObject, SZWebViewBridgeHandlerProtocol {
    public weak var viewController: UIViewController?
    public weak var webViewBridge: SZWebViewBridge?
    public var action: String?
    public var params: [String: Any]?
    public var callbackId: SZWebViewBridgeCallbackId = -1
    public var isValidCallbackId: Bool {
        return callbackId >= 0
    }

    private struct invokeError: Error {
        let msg: String
        init(_ message: String) {
            msg = message
        }
    }

    open func invoke() throws {
        throw invokeError("invoke() has not been implemented")
    }

    required override public init() {
        super.init()
    }

}
