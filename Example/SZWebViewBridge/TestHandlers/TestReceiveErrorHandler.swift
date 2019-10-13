//
//  TestReceiveErrorHandler.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SZWebViewBridge

class TestReceiveErrorHandler: SZWebViewBridgeBaseHandler {

    override func invoke() throws {
        guard let params = params else { return }

        print(params)
        if let webViewBridge = webViewBridge {
            if isValidCallbackId {
                let error: SZWebViewBridgeError = SZWebViewBridgeError(code: -999, description: "Some test error message")
                let result: SZWebViewBridgeResult = .failure(error)
                webViewBridge.callback(callbackId: callbackId, result: result)
            }
        }

    }

}
