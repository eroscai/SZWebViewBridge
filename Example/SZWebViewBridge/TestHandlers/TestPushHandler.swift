//
//  TestPushHandler.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SZWebViewBridge

class TestPushHandler: SZWebViewBridgeBaseHandler {

    override func invoke() throws {
        if let viewController = viewController {
            let vc = ViewController()
            viewController.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
