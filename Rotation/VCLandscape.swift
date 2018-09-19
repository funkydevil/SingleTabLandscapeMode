//
//  ViewController.swift
//  Rotation
//
//  Created by Kirill Pyulzyu on 19.09.2018.
//  Copyright © 2018 KP. All rights reserved.
//

import UIKit
import WebKit

class VCLandscape: UIViewController {
    @IBOutlet weak var webview: WKWebView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "chartWidget", ofType: "html") {
            webview.load(URLRequest(url: URL(fileURLWithPath: path)))
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.landscapeLeft.rawValue), forKey: "orientation")
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        
    }
    
    @objc func onlyLandscape() -> Void {}
}




