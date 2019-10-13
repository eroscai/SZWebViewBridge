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
        let rightItem = UIBarButtonItem(title: "Change", style: .plain, target: self, action: #selector(handleRightItemClick))
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

    @objc func handleRightItemClick() {
        webViewBridge.post(action: "change", params: nil)
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
