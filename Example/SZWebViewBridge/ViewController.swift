//
//  ViewController.swift
//  SZWebViewBridge
//
//  Created by eroscai on 10/12/2019.
//  Copyright (c) 2019 eroscai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private lazy var wkWebViewEnterBtn: UIButton = createWKWebViewEnterBtn()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(wkWebViewEnterBtn)
    }

    @objc func goWKWebViewVC() {
        let vc = WKWebViewVC()
        navigationController?.pushViewController(vc, animated: true)
    }

}

// MARK: - Getter

extension ViewController {

    func createWKWebViewEnterBtn() -> UIButton {
        let btn = UIButton()
        btn.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        let screenBounds = UIScreen.main.bounds
        btn.center = CGPoint(x: screenBounds.width / 2, y: screenBounds.height / 2)
        btn.setTitle("WKWebView", for: .normal)
        btn.addTarget(self, action: #selector(goWKWebViewVC), for: .touchUpInside)

        return btn
    }

}

