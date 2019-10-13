//
//  TitleHandler.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/12.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

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
