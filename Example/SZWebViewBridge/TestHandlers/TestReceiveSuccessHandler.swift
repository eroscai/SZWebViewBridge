//
//  TestReceiveSuccessHandler.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

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
