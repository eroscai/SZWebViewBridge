//
//  AlertHandler.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import SZWebViewBridge

class AlertHandler: SZWebViewBridgeBaseHandler {

    override func invoke() throws {
        guard let params = params else { return }

        var title: String?
        if let titleValue = params["title"] as? String {
            title = titleValue
        }

        var message: String?
        if let messageValue = params["message"] as? String {
            message = messageValue
        }

        if let viewController = viewController {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }

}
