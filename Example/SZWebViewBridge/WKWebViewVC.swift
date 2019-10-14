//
//  WKWebViewVC.swift
//  SZWebViewBridge_Example
//
//  Created by CaiSanze on 2019/10/13.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import WebKit
import SZWebViewBridge

class WKWebViewVC: UIViewController {

    private lazy var webView: WKWebView = createWebView()
    private lazy var webViewBridge: SZWebViewBridge = createWebViewBridge()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        let rightItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(handleRightItemClick))
        navigationItem.rightBarButtonItem = rightItem

        view.addSubview(webView)
        if let localHtml = Bundle.main.url(forResource: "test", withExtension: "html") {
            webView.load(URLRequest(url: localHtml))
        }

        var handlers: SZWebViewBridgeBaseHandlerObject {
            return [
                "setTitle": TitleHandler.self,
                "alert": AlertHandler.self,
                "testError": TestReceiveErrorHandler.self,
                "testSuccess": TestReceiveSuccessHandler.self,
                "testPush": TestPushHandler.self,
            ]
        }
        webViewBridge.addHandlers(handlers: handlers)

    }

}

// MARK: - Actions

extension WKWebViewVC {

    @objc func handleRightItemClick() {
        let alertVC = UIAlertController(title: "Choose Action", message: nil, preferredStyle: .actionSheet)
        let changeAtion = UIAlertAction(title: "Change", style: .default) { [weak self] (action) in
            self?.webViewBridge.post(action: "change", params: nil)
        }
        let removeAllAtion = UIAlertAction(title: "Remove All", style: .default) { [weak self] (action) in
            let actions: [String] = ["setTitle" , "alert", "testError", "testSuccess", "testPush"]
            self?.webViewBridge.removeHandlers(handlerActions: actions)
        }
        let addAllAtion = UIAlertAction(title: "Add All", style: .default) { [weak self] (action) in
            let actions: SZWebViewBridgeBaseHandlerObject = [
                "setTitle": TitleHandler.self,
                "alert": AlertHandler.self,
                "testError": TestReceiveErrorHandler.self,
                "testSuccess": TestReceiveSuccessHandler.self,
                "testPush": TestPushHandler.self,
            ]
            self?.webViewBridge.addHandlers(handlers: actions)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertVC.addAction(changeAtion)
        alertVC.addAction(removeAllAtion)
        alertVC.addAction(addAllAtion)
        alertVC.addAction(cancelAction)

        present(alertVC, animated: true, completion: nil)
    }

}

// MARK: - Getter

extension WKWebViewVC {

    func createWebView() -> WKWebView {
        let bounds = UIScreen.main.bounds
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height))

        return webView
    }

    func createWebViewBridge() -> SZWebViewBridge {
        let bridge = SZWebViewBridge(webView: webView, viewController: self)

        return bridge
    }

}
