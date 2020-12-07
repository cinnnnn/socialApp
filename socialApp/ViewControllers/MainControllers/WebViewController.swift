//
//  WebViewController.swift
//  socialApp
//
//  Created by Денис Щиголев on 06.12.2020.
//  Copyright © 2020 Денис Щиголев. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {

    let webView = WKWebView()
    let urlToOpen: URL
    
    init(urlToOpen: URL) {
        self.urlToOpen = urlToOpen
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRequest()
    }
    
    private func loadRequest() {
        let myRequest = URLRequest(url: urlToOpen)
        webView.load(myRequest)
    }
}
